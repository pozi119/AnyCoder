//
//  Factory.swift
//  AnyCoder
//
//  Created by Valo on 2022/7/20.
//

import Foundation
import Runtime

#if !canImport(Foundation)
    extension Decimal: DefaultConstructor {}
    extension Date: DefaultConstructor {}
    extension UUID: DefaultConstructor {}
    extension Data: DefaultConstructor {}
#endif

extension NSString: DefaultConstructor {}
extension NSNumber: DefaultConstructor {}
extension NSData: DefaultConstructor {}

struct ClassMetadataLayout {
    var _kind: Int // isaPointer for classes
    var superClass: Any.Type
    var objCRuntimeReserve: (Int, Int)
    var rodataPointer: Int
    var classFlags: Int32
    var instanceAddressPoint: UInt32
    var instanceSize: UInt32
    var instanceAlignmentMask: UInt16
    var reserved: UInt16
    var classSize: UInt32
    var classAddressPoint: UInt32
    var typeDescriptor: UnsafeRawPointer
    var iVarDestroyer: UnsafeRawPointer
}

public func xCreateInstance(of type: Any.Type, constructor: ((PropertyInfo) throws -> Any)? = nil) throws -> Any {
    if let defaultConstructor = type as? DefaultConstructor.Type {
        return defaultConstructor.init()
    }

    let info = try typeInfo(of: type)
    let kind = info.kind
    switch kind {
    case .struct:
        return try xBuildStruct(type: type, info: info, constructor: constructor)
    case .class:
        return try xBuildClass(type: type, info: info)
    case .enum:
        fallthrough
    case .tuple:
        return try xBuildStruct(type: type, info: info, constructor: constructor)
    default:
        throw DecodingError.mismatch(type)
    }
}

func xBuildStruct(type: Any.Type, info: TypeInfo, constructor: ((PropertyInfo) throws -> Any)? = nil) throws -> Any {
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: info.size, alignment: info.alignment)
    defer { pointer.deallocate() }
    try setProperties(typeInfo: info, pointer: pointer, constructor: constructor)
    return getters(type: type).get(from: pointer)
}

func xBuildClass(type: Any.Type, info: TypeInfo) throws -> Any {
    let pointer = unsafeBitCast(type, to: UnsafeMutablePointer<ClassMetadataLayout>.self)
    let metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
    let instanceSize = Int32(pointer.pointee.classSize)
    let alignment = Int32(info.alignment)

    guard let value = swift_allocObject(metadata, instanceSize, alignment) else {
        throw DecodingError.mismatch(type)
    }

    try setProperties(typeInfo: info, pointer: UnsafeMutableRawPointer(mutating: value))

    return unsafeBitCast(value, to: AnyObject.self)
}

func setProperties(typeInfo: TypeInfo,
                   pointer: UnsafeMutableRawPointer,
                   constructor: ((PropertyInfo) throws -> Any)? = nil) throws {
    for property in typeInfo.properties {
        let value = try constructor.map { resolver -> Any in
            try resolver(property)
        } ?? defaultValue(of: property.type)

        let valuePointer = pointer.advanced(by: property.offset)
        let sets = setters(type: property.type)
        sets.set(value: value, pointer: valuePointer, initialize: true)
    }
}

func defaultValue(of type: Any.Type) throws -> Any {
    if let constructable = type as? DefaultConstructor.Type {
        return constructable.init()
    } else if let isOptional = type as? ExpressibleByNilLiteral.Type {
        return isOptional.init(nilLiteral: ())
    }

    return try xCreateInstance(of: type)
}

//
//  GettersSetters.swift
//  AnyCoder
//
//  Created by Valo on 2022/7/20.
//

struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable: Int
}

protocol Getters {}
extension Getters {
    static func get(from pointer: UnsafeRawPointer) -> Any {
        return pointer.assumingMemoryBound(to: Self.self).pointee
    }
}

func getters(type: Any.Type) -> Getters.Type {
    let container = ProtocolTypeContainer(type: type, witnessTable: 0)
    return unsafeBitCast(container, to: Getters.Type.self)
}

protocol Setters {}
extension Setters {
    static func set(value: Any, pointer: UnsafeMutableRawPointer, initialize: Bool = false) {
        if let value = value as? Self {
            let boundPointer = pointer.assumingMemoryBound(to: self)
            if initialize {
                boundPointer.initialize(to: value)
            } else {
                boundPointer.pointee = value
            }
        }
    }
}

func setters(type: Any.Type) -> Setters.Type {
    let container = ProtocolTypeContainer(type: type, witnessTable: 0)
    return unsafeBitCast(container, to: Setters.Type.self)
}

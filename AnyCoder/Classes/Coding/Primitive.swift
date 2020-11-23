//
//  Primitive.swift
//  AnyCoder
//
//  Created by Valo on 2020/11/20.
//

import Foundation

public protocol Primitive {}

extension Bool: Primitive {}
extension Int: Primitive {}
extension Int8: Primitive {}
extension Int16: Primitive {}
extension Int32: Primitive {}
extension Int64: Primitive {}
extension UInt: Primitive {}
extension UInt8: Primitive {}
extension UInt16: Primitive {}
extension UInt32: Primitive {}
extension UInt64: Primitive {}
extension Float: Primitive {}
extension Double: Primitive {}

extension String: Primitive {}
extension Data: Primitive {}

extension Primitive {
    init?(Primitive: Primitive) {
        if let value = Primitive as? Self {
            self = value
            return
        }

        var value: Any?
        switch (Primitive, Self.self) {
        case (let string as String, is Data.Type):
            value = Data(hex: string)
        case (let data as Data, is String.Type):
            value = data.hex
        case (_, is String.Type):
            value = String(describing: Primitive)
        default:
            break
        }

        guard let result = value as? Self else {
            return nil
        }
        self = result
    }
}

extension Primitive where Self: BinaryInteger {
    init?<T: BinaryInteger>(Primitive: T) {
        self.init(Primitive)
    }
}

extension Primitive where Self: BinaryFloatingPoint {
    init?<T: BinaryFloatingPoint>(Primitive: T) {
        self.init(Primitive)
    }
}

extension Primitive where Self: LosslessStringConvertible {
    init?(Primitive: Primitive) {
        self.init(String(describing: Primitive))
    }
}

extension String {
    init(bytes: [UInt8]) {
        self = String(bytes: bytes, encoding: .utf8) ?? String(bytes: bytes, encoding: .ascii) ?? ""
    }

    var bytes: [UInt8] { utf8.map { UInt8($0) }}
}

extension Data {
    private static let hexTable: [UInt8] = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46]

    private static func hexDigit(_ byte: UInt8) -> UInt8 {
        switch byte {
        case 0x30 ... 0x39: return byte - 0x30
        case 0x41 ... 0x46: return byte - 0x41 + 0xA
        case 0x61 ... 0x66: return byte - 0x61 + 0xA
        default: return 0xFF
        }
    }

    public var bytes: [UInt8] { [UInt8](self) }

    public var hex: String {
        var hexBytes: [UInt8] = []
        for byte in bytes {
            let hi = Data.hexTable[Int((byte >> 4) & 0xF)]
            let lo = Data.hexTable[Int(byte & 0xF)]
            hexBytes.append(hi)
            hexBytes.append(lo)
        }
        return String(bytes: hexBytes)
    }

    init(hex: String) {
        let chars = hex.bytes
        guard chars.count % 2 == 0 else { self.init(); return }
        let len = chars.count / 2
        var buffer: [UInt8] = []
        for i in 0 ..< len {
            let h = Data.hexDigit(chars[i * 2])
            let l = Data.hexDigit(chars[i * 2 + 1])
            guard h != 0xFF || l != 0xFF else { self.init(); return }
            let b = h << 4 | l
            buffer.append(b)
        }
        self.init(buffer)
    }
}

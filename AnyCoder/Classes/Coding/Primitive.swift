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

public extension Primitive {
    init?(primitive: Primitive) {
        var value: Any?
        switch Self.self {
        case is Int.Type:
            switch primitive {
            case let int as Int: value = int
            case let int8 as Int8: value = Int(truncatingIfNeeded: int8)
            case let int16 as Int16: value = Int(truncatingIfNeeded: int16)
            case let int32 as Int32: value = Int(truncatingIfNeeded: int32)
            case let int64 as Int64: value = Int(truncatingIfNeeded: int64)
            case let uint as UInt: value = Int(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = Int(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = Int(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = Int(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = Int(truncatingIfNeeded: uint64)
            case let bool as Bool: value = Int(bool ? 1 : 0)
            case let float as Float: value = Int(float)
            case let double as Double: value = Int(double)
            case let string as String: value = Int(string)
            case let data as Data: value = Int(data: data)
            default: break
            }

        case is Int8.Type:
            switch primitive {
            case let int as Int: value = Int8(truncatingIfNeeded: int)
            case let int8 as Int8: value = int8
            case let int16 as Int16: value = Int8(truncatingIfNeeded: int16)
            case let int32 as Int32: value = Int8(truncatingIfNeeded: int32)
            case let int64 as Int64: value = Int8(truncatingIfNeeded: int64)
            case let uint as UInt: value = Int8(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = Int8(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = Int8(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = Int8(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = Int8(truncatingIfNeeded: uint64)
            case let bool as Bool: value = Int8(bool ? 1 : 0)
            case let float as Float: value = Int8(float)
            case let double as Double: value = Int8(double)
            case let string as String: value = Int8(string)
            case let data as Data: value = Int8(data: data)
            default: break
            }

        case is Int16.Type:
            switch primitive {
            case let int as Int: value = Int16(truncatingIfNeeded: int)
            case let int8 as Int8: value = Int16(truncatingIfNeeded: int8)
            case let int16 as Int16: value = int16
            case let int32 as Int32: value = Int16(truncatingIfNeeded: int32)
            case let int64 as Int64: value = Int16(truncatingIfNeeded: int64)
            case let uint as UInt: value = Int16(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = Int16(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = Int16(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = Int16(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = Int16(truncatingIfNeeded: uint64)
            case let bool as Bool: value = Int16(bool ? 1 : 0)
            case let float as Float: value = Int16(float)
            case let double as Double: value = Int16(double)
            case let string as String: value = Int16(string)
            case let data as Data: value = Int16(data: data)
            default: break
            }

        case is Int32.Type:
            switch primitive {
            case let int as Int: value = Int32(truncatingIfNeeded: int)
            case let int8 as Int8: value = Int32(truncatingIfNeeded: int8)
            case let int16 as Int16: value = Int32(truncatingIfNeeded: int16)
            case let int32 as Int32: value = int32
            case let int64 as Int64: value = Int32(truncatingIfNeeded: int64)
            case let uint as UInt: value = Int32(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = Int32(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = Int32(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = Int32(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = Int32(truncatingIfNeeded: uint64)
            case let bool as Bool: value = Int32(bool ? 1 : 0)
            case let float as Float: value = Int32(float)
            case let double as Double: value = Int32(double)
            case let string as String: value = Int32(string)
            case let data as Data: value = Int(data: data)
            default: break
            }

        case is Int64.Type:
            switch primitive {
            case let int as Int: value = Int64(truncatingIfNeeded: int)
            case let int8 as Int8: value = Int64(truncatingIfNeeded: int8)
            case let int16 as Int16: value = Int64(truncatingIfNeeded: int16)
            case let int32 as Int32: value = Int64(truncatingIfNeeded: int32)
            case let int64 as Int64: value = int64
            case let uint as UInt: value = Int64(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = Int64(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = Int64(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = Int64(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = Int64(truncatingIfNeeded: uint64)
            case let bool as Bool: value = Int64(bool ? 1 : 0)
            case let float as Float: value = Int64(float)
            case let double as Double: value = Int64(double)
            case let string as String: value = Int64(string)
            case let data as Data: value = Int64(data: data)
            default: break
            }

        case is UInt.Type:
            switch primitive {
            case let int as Int: value = UInt(truncatingIfNeeded: int)
            case let int8 as Int8: value = UInt(truncatingIfNeeded: int8)
            case let int16 as Int16: value = UInt(truncatingIfNeeded: int16)
            case let int32 as Int32: value = UInt(truncatingIfNeeded: int32)
            case let int64 as Int64: value = UInt(truncatingIfNeeded: int64)
            case let uint as UInt: value = uint
            case let uint8 as UInt8: value = UInt(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = UInt(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = UInt(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = UInt(truncatingIfNeeded: uint64)
            case let bool as Bool: value = UInt(bool ? 1 : 0)
            case let float as Float: value = UInt(float)
            case let double as Double: value = UInt(double)
            case let string as String: value = UInt(string)
            case let data as Data: value = UInt(data: data)
            default: break
            }

        case is UInt8.Type:
            switch primitive {
            case let int as Int: value = UInt8(truncatingIfNeeded: int)
            case let int8 as Int8: value = UInt8(truncatingIfNeeded: int8)
            case let int16 as Int16: value = UInt8(truncatingIfNeeded: int16)
            case let int32 as Int32: value = UInt8(truncatingIfNeeded: int32)
            case let int64 as Int64: value = UInt8(truncatingIfNeeded: int64)
            case let uint as UInt: value = UInt8(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = uint8
            case let uint16 as UInt16: value = UInt8(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = UInt8(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = UInt8(truncatingIfNeeded: uint64)
            case let bool as Bool: value = UInt8(bool ? 1 : 0)
            case let float as Float: value = UInt8(float)
            case let double as Double: value = UInt8(double)
            case let string as String: value = UInt8(string)
            case let data as Data: value = UInt8(data: data)
            default: break
            }

        case is UInt16.Type:
            switch primitive {
            case let int as Int: value = UInt16(truncatingIfNeeded: int)
            case let int8 as Int8: value = UInt16(truncatingIfNeeded: int8)
            case let int16 as Int16: value = UInt16(truncatingIfNeeded: int16)
            case let int32 as Int32: value = UInt16(truncatingIfNeeded: int32)
            case let int64 as Int64: value = UInt16(truncatingIfNeeded: int64)
            case let uint as UInt: value = UInt16(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = UInt16(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = uint16
            case let uint32 as UInt32: value = UInt16(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = UInt16(truncatingIfNeeded: uint64)
            case let bool as Bool: value = UInt16(bool ? 1 : 0)
            case let float as Float: value = UInt16(float)
            case let double as Double: value = UInt16(double)
            case let string as String: value = UInt16(string)
            case let data as Data: value = UInt16(data: data)
            default: break
            }

        case is UInt32.Type:
            switch primitive {
            case let int as Int: value = UInt32(truncatingIfNeeded: int)
            case let int8 as Int8: value = UInt32(truncatingIfNeeded: int8)
            case let int16 as Int16: value = UInt32(truncatingIfNeeded: int16)
            case let int32 as Int32: value = UInt32(truncatingIfNeeded: int32)
            case let int64 as Int64: value = UInt32(truncatingIfNeeded: int64)
            case let uint as UInt: value = UInt32(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = UInt32(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = UInt32(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = uint32
            case let uint64 as UInt64: value = UInt32(truncatingIfNeeded: uint64)
            case let bool as Bool: value = UInt32(bool ? 1 : 0)
            case let float as Float: value = UInt32(float)
            case let double as Double: value = UInt32(double)
            case let string as String: value = UInt32(string)
            case let data as Data: value = UInt32(data: data)
            default: break
            }

        case is UInt64.Type:
            switch primitive {
            case let int as Int: value = UInt64(truncatingIfNeeded: int)
            case let int8 as Int8: value = UInt64(truncatingIfNeeded: int8)
            case let int16 as Int16: value = UInt64(truncatingIfNeeded: int16)
            case let int32 as Int32: value = UInt64(truncatingIfNeeded: int32)
            case let int64 as Int64: value = UInt64(truncatingIfNeeded: int64)
            case let uint as UInt: value = UInt64(truncatingIfNeeded: uint)
            case let uint8 as UInt8: value = UInt64(truncatingIfNeeded: uint8)
            case let uint16 as UInt16: value = UInt64(truncatingIfNeeded: uint16)
            case let uint32 as UInt32: value = UInt64(truncatingIfNeeded: uint32)
            case let uint64 as UInt64: value = uint64
            case let bool as Bool: value = UInt64(bool ? 1 : 0)
            case let float as Float: value = UInt64(float)
            case let double as Double: value = UInt64(double)
            case let string as String: value = UInt64(string)
            case let data as Data: value = UInt64(data: data)
            default: break
            }

        case is Bool.Type:
            switch primitive {
            case let int as Int: value = int > 0
            case let int8 as Int8: value = int8 > 0
            case let int16 as Int16: value = int16 > 0
            case let int32 as Int32: value = int32 > 0
            case let int64 as Int64: value = int64 > 0
            case let uint as UInt: value = uint > 0
            case let uint8 as UInt8: value = uint8 > 0
            case let uint16 as UInt16: value = uint16 > 0
            case let uint32 as UInt32: value = uint32 > 0
            case let uint64 as UInt64: value = uint64 > 0
            case let bool as Bool: value = bool
            case let float as Float: value = float > 0
            case let double as Double: value = double > 0
            case let string as String: value = (Int(string) ?? 0) > 0
            case let data as Data: value = data.bytes[0] > 0
            default: break
            }

        case is Float.Type:
            switch primitive {
            case let int as Int: value = Float(int)
            case let int8 as Int8: value = Float(int8)
            case let int16 as Int16: value = Float(int16)
            case let int32 as Int32: value = Float(int32)
            case let int64 as Int64: value = Float(int64)
            case let uint as UInt: value = Float(uint)
            case let uint8 as UInt8: value = Float(uint8)
            case let uint16 as UInt16: value = Float(uint16)
            case let uint32 as UInt32: value = Float(uint32)
            case let uint64 as UInt64: value = Float(uint64)
            case let bool as Bool: value = Float(bool ? 1 : 0)
            case let float as Float: value = float
            case let double as Double: value = Float(double)
            case let string as String: value = Float(string)
            case let data as Data: value = Float(data: data)
            default: break
            }

        case is Double.Type:
            switch primitive {
            case let int as Int: value = Double(int)
            case let int8 as Int8: value = Double(int8)
            case let int16 as Int16: value = Double(int16)
            case let int32 as Int32: value = Double(int32)
            case let int64 as Int64: value = Double(int64)
            case let uint as UInt: value = Double(uint)
            case let uint8 as UInt8: value = Double(uint8)
            case let uint16 as UInt16: value = Double(uint16)
            case let uint32 as UInt32: value = Double(uint32)
            case let uint64 as UInt64: value = Double(uint64)
            case let bool as Bool: value = Double(bool ? 1 : 0)
            case let float as Float: value = Double(float)
            case let double as Double: value = double
            case let string as String: value = Double(string)
            case let data as Data: value = Double(data: data)
            default: break
            }

        case is String.Type:
            switch primitive {
            case let int as Int: value = String(int)
            case let int8 as Int8: value = String(int8)
            case let int16 as Int16: value = String(int16)
            case let int32 as Int32: value = String(int32)
            case let int64 as Int64: value = String(int64)
            case let uint as UInt: value = String(uint)
            case let uint8 as UInt8: value = String(uint8)
            case let uint16 as UInt16: value = String(uint16)
            case let uint32 as UInt32: value = String(uint32)
            case let uint64 as UInt64: value = String(uint64)
            case let bool as Bool: value = String(bool ? 1 : 0)
            case let float as Float: value = String(float)
            case let double as Double: value = String(double)
            case let string as String: value = string
            case let data as Data: value = data.hex
            default: break
            }

        case is Data.Type:
            switch primitive {
            case let int as Int: value = Data(integer: int)
            case let int8 as Int8: value = Data(integer: int8)
            case let int16 as Int16: value = Data(integer: int16)
            case let int32 as Int32: value = Data(integer: int32)
            case let int64 as Int64: value = Data(integer: int64)
            case let uint as UInt: value = Data(integer: uint)
            case let uint8 as UInt8: value = Data(integer: uint8)
            case let uint16 as UInt16: value = Data(integer: uint16)
            case let uint32 as UInt32: value = Data(integer: uint32)
            case let uint64 as UInt64: value = Data(integer: uint64)
            case let bool as Bool: value = Data((bool ? 1 : 0).bytes)
            case let float as Float: value = Data(floating: float)
            case let double as Double: value = Data(floating: double)
            case let string as String:
                var data = Data(hex: string)
                if data.count == 0 && string.count > 0 {
                    data = Data(string.bytes)
                }
                value = data
            case let data as Data: value = data
            default: break
            }

        default: break
        }
        guard let result = value as? Self else { return nil }
        self = result
    }
}

public extension BinaryInteger {
    init(data: Data) {
        let bytes = data.bytes
        let uint64 = (0 ..< bytes.count).reduce(0) { $0 & (UInt64(bytes[$1]) << ($1 * 8)) }
        self.init(truncatingIfNeeded: uint64)
    }

    var bytes: [UInt8] {
        let uint64 = UInt64(truncatingIfNeeded: self)
        return (0 ..< (bitWidth / 8)).reduce([]) { $0 + [UInt8((uint64 >> (UInt64($1) * 8)) & UInt64(0xFF))] }
    }
}

public extension BinaryFloatingPoint {
    init(data: Data) {
        let bytes = data.bytes
        let uint64 = (0 ..< bytes.count).reduce(0) { $0 & (UInt64(bytes[$1]) << ($1 * 8)) }
        self.init(uint64)
    }

    var bytes: [UInt8] {
        let uint64 = UInt64(self)
        return (0 ..< 8).reduce([]) { $0 + [UInt8((uint64 >> (UInt64($1) * 8)) & UInt64(0xFF))] }
    }
}

public extension String {
    init(bytes: [UInt8]) {
        self = String(bytes: bytes, encoding: .utf8) ?? String(bytes: bytes, encoding: .ascii) ?? ""
    }

    var bytes: [UInt8] { utf8.map { UInt8($0) }}
}

public extension Data {
    private static let hexTable: [UInt8] = [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46]

    private static func hexDigit(_ byte: UInt8) -> UInt8 {
        switch byte {
        case 0x30 ... 0x39: return byte - 0x30
        case 0x41 ... 0x46: return byte - 0x41 + 0xA
        case 0x61 ... 0x66: return byte - 0x61 + 0xA
        default: return 0xFF
        }
    }

    var bytes: [UInt8] { [UInt8](self) }

    var hex: String {
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

    init<T>(integer: T) where T: BinaryInteger {
        self.init(integer.bytes)
    }

    init<T>(floating: T) where T: BinaryFloatingPoint {
        self.init(floating.bytes)
    }
}

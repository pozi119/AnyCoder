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

extension NSNumber: Primitive {}
extension NSString: Primitive {}
extension NSData: Primitive {}

public extension Primitive {
    init?(primitive: Primitive) {
        if let p = primitive as? Self {
            self = p
            return
        }
        var r: Any?
        switch Self.self {
        case let k as any BinaryInteger.Type:
            switch primitive {
            case let v as any BinaryInteger:
                r = k.init(truncatingIfNeeded: v) as! Self
            case let v as any BinaryFloatingPoint:
                r = k.init(v) as! Self
            case let v as NSNumber:
                if let k = k as? any SignedInteger.Type {
                    r = k.init(truncatingIfNeeded: v.int64Value) as! Self
                } else {
                    r = k.init(truncatingIfNeeded: v.uint64Value) as! Self
                }
            case let v as Bool:
                r = k.init(truncatingIfNeeded: v ? 1 : 0) as! Self
            case let v as Data:
                r = k.init(data: v) as! Self
            case let v as NSData:
                r = k.init(data: v as Data) as! Self
            default: break
            }

        case let k as any BinaryFloatingPoint.Type:
            if r != nil { break }
            switch primitive {
            case let v as any BinaryInteger:
                r = k.init(v) as! Self
            case let v as any BinaryFloatingPoint:
                r = k.init(v) as! Self
            case let v as NSNumber:
                r = k.init(v.doubleValue) as! Self
            case let v as Bool:
                r = k.init(v ? 1.0 : 0.0) as! Self
            case let v as Data:
                r = k.init(data: v) as! Self
            case let v as NSData:
                r = k.init(data: v as Data) as! Self
            default: break
            }

        case is Bool.Type:
            if r != nil { break }
            switch primitive {
            case _ as any BinaryInteger:
                r = (Int64(primitive: primitive) ?? 0) > 0
            case _ as any BinaryFloatingPoint:
                r = (Double(primitive: primitive) ?? 0) > 0
            case let v as NSNumber:
                r = v.boolValue
            case let v as Data:
                r = v.bytes.first ?? 0 > 0
            case let v as NSData:
                r = (v as Data).bytes.first ?? 0 > 0
            default: break
            }

        case is Data.Type:
            if r != nil { break }
            switch primitive {
            case let v as any BinaryInteger:
                r = Data(integer: v)
            case let v as any BinaryFloatingPoint:
                r = Data(floating: v)
            case let v as NSNumber:
                r = v.doubleValue != 0 ? Data(floating: v.doubleValue) : Data(integer: v.uint64Value)
            case let v as NSData:
                r = (v as Data)
            case let v as String:
                r = Data(hex: v)
            case let v as NSString:
                r = Data(hex: v as String)
            default: break
            }

        case is String.Type:
            if r != nil { break }
            switch primitive {
            case let v as CustomStringConvertible:
                r = v.description
            default:
                r = "\(primitive)"
            }

        case is NSString.Type:
            if r != nil { break }
            switch primitive {
            case let v as CustomStringConvertible:
                r = v.description as NSString
            default:
                r = "\(primitive)" as NSString
            }
        case is NSNumber.Type:
            if r != nil { break }
            r = NSNumber(value: Double(primitive: primitive) ?? 0)

        case let k as any LosslessStringConvertible.Type:
            if r != nil { break }
            switch primitive {
            case let v as String:
                r = k.init(v)
            case let v as NSString:
                r = k.init(v as String)
            default: break
            }
        default: break
        }

        guard let result = r as? Self else { return nil }
        self = result
    }
}

public extension BinaryInteger {
    init(data: Data) {
        let bytes = data.bytes
        let uint64 = (0 ..< bytes.count).reduce(0) { $0 | (UInt64(bytes[$1]) << ($1 * 8)) }
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

public extension RawRepresentable {
    init?(primitive: Primitive) {
        guard let val = primitive as? Self.RawValue else { return nil }
        self.init(rawValue: val)
    }
}

public extension Array {
    func splat(_ num: Int) -> Any? {
        guard num > 0, num <= count, num <= 10 else { return nil }
        switch num {
        case 1: return (self[0])
        case 2: return (self[0], self[1])
        case 3: return (self[0], self[1], self[2])
        case 4: return (self[0], self[1], self[2], self[3])
        case 5: return (self[0], self[1], self[2], self[3], self[4])
        case 6: return (self[0], self[1], self[2], self[3], self[4], self[5])
        case 7: return (self[0], self[1], self[2], self[3], self[4], self[5], self[6])
        case 8: return (self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7])
        case 9: return (self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8])
        case 10: return (self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9])
        default: return nil
        }
    }
}

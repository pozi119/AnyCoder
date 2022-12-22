//
//  ManyCoder.swift
//  AnyCoder
//
//  Created by Valo on 2019/5/7.
//

import Foundation

fileprivate final class Storage {
    private(set) var containers: [Any] = []

    var count: Int {
        return containers.count
    }

    var last: Any? {
        return containers.last
    }

    func push(_ container: Any) {
        containers.append(container)
    }

    @discardableResult
    func popContainer() -> Any {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}

fileprivate struct ManyCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        stringValue = "Index \(index)"
        intValue = index
    }

    static let `super` = ManyCodingKey(stringValue: "super")!
}

func cast<T>(_ item: Any?, as type: T.Type) throws -> T {
    if let value = item as? T {
        return value
    }

    guard let primitive = item as? Primitive else {
        throw EncodingError.invalidCast(item as Any, type)
    }

    if let type = type as? Primitive.Type,
       let result = type.init(primitive: primitive) as? T {
        return result
    }

    return try xCreateInstance(of: type) as! T
}

open class ManyEncoder: Encoder {
    open var codingPath: [CodingKey] = []
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    private var storage = Storage()

    public init() {}

    open func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self, codingPath: codingPath))
    }

    open func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self, codingPath: codingPath)
    }

    open func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueContainer(encoder: self, codingPath: codingPath)
    }

    private func box<T: Encodable>(_ value: T) throws -> Any {
        try value.encode(to: self)
        return storage.popContainer()
    }
}

extension ManyEncoder {
    public func encode<T: Encodable>(_ value: T) throws -> [String: Primitive] {
        do {
            let temp = try cast(try box(value), as: [String: Any].self)
            var encoded: [String: Primitive] = [:]
            for (key, value) in temp {
                switch value {
                case let value as Primitive:
                    encoded[key] = value
                case _ as NSNull:
                    break
                default:
                    let data = try JSONSerialization.data(withJSONObject: value, options: [])
                    let string = String(bytes: data.bytes)
                    encoded[key] = string
                }
            }
            return encoded
        } catch let error {
            throw EncodingError.invalidEncode(value, error)
        }
    }

    public func encode<T: Encodable>(_ values: [T]) -> [[String: Primitive]] {
        var array = [[String: Primitive]]()
        for value in values {
            do {
                let encoded = try encode(value)
                array.append(encoded)
            } catch _ {
                array.append([:])
            }
        }
        return array
    }
}

extension ManyEncoder {
    private class KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        private var encoder: ManyEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage

        init(encoder: ManyEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            storage = encoder.storage

            storage.push([:] as [String: Any])
        }

        deinit {
            guard let dictionary = storage.popContainer() as? [String: Any] else {
                assertionFailure()
                return
            }
            storage.push(dictionary)
        }

        private func set(_ value: Any, forKey key: String) {
            guard var dictionary = storage.popContainer() as? [String: Any] else {
                assertionFailure()
                return
            }
            dictionary[key] = value
            storage.push(dictionary)
        }

        private func wrap<T: Encodable>(_ value: T) throws -> Any {
            if let data = value as? Data {
                return data
            }
            let depth = storage.count
            do {
                try value.encode(to: encoder)
            } catch {
                if storage.count > depth {
                    _ = storage.popContainer()
                }
                throw EncodingError.invalidWrap(value, error)
            }
            return storage.popContainer()
        }

        func encodeNil(forKey key: Key) throws { set(NSNull(), forKey: key.stringValue) }
        func encode(_ value: Bool, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int8, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int16, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int32, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int64, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt8, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt16, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt32, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt64, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Float, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Double, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: String, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            encoder.codingPath.append(key)
            defer { encoder.codingPath.removeLast() }
            set(try wrap(value), forKey: key.stringValue)
        }

        func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T: Encodable {
            encoder.codingPath.append(key)
            defer { encoder.codingPath.removeLast() }
            if let data = value as? Data {
                set(data.hex, forKey: key.stringValue)
            } else {
                set(try wrap(value), forKey: key.stringValue)
            }
        }

        func encodeConditional<T>(_ object: T, forKey key: Key) throws where T: AnyObject, T: Encodable {
            encoder.codingPath.append(key)
            defer { encoder.codingPath.removeLast() }
            set(try wrap(object), forKey: key.stringValue)
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            codingPath.append(key)
            defer { codingPath.removeLast() }
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            codingPath.append(key)
            defer { codingPath.removeLast() }
            return UnkeyedContanier(encoder: encoder, codingPath: codingPath)
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }

    private class UnkeyedContanier: UnkeyedEncodingContainer {
        var encoder: ManyEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage
        var count: Int { return storage.count }

        init(encoder: ManyEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            storage = encoder.storage

            storage.push([] as [Any])
        }

        deinit {
            guard let array = storage.popContainer() as? [Any] else {
                assertionFailure()
                return
            }
            storage.push(array)
        }

        private func push(_ value: Any) {
            guard var array = storage.popContainer() as? [Any] else {
                assertionFailure()
                return
            }
            array.append(value)
            storage.push(array)
        }

        func encodeNil() throws { push(NSNull()) }
        func encode(_ value: Bool) throws { push(try encoder.box(value)) }
        func encode(_ value: Int) throws { push(try encoder.box(value)) }
        func encode(_ value: Int8) throws { push(try encoder.box(value)) }
        func encode(_ value: Int16) throws { push(try encoder.box(value)) }
        func encode(_ value: Int32) throws { push(try encoder.box(value)) }
        func encode(_ value: Int64) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt8) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt16) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt32) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt64) throws { push(try encoder.box(value)) }
        func encode(_ value: Float) throws { push(try encoder.box(value)) }
        func encode(_ value: Double) throws { push(try encoder.box(value)) }
        func encode(_ value: String) throws { push(try encoder.box(value)) }
        func encode<T: Encodable>(_ value: T) throws {
            encoder.codingPath.append(ManyCodingKey(index: count))
            defer { encoder.codingPath.removeLast() }
            push(try encoder.box(value))
        }

        func encodeConditional<T>(_ object: T) throws where T: AnyObject, T: Encodable {
            encoder.codingPath.append(ManyCodingKey(index: count))
            defer { encoder.codingPath.removeLast() }
            push(try encoder.box(object))
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
            codingPath.append(ManyCodingKey(index: count))
            defer { codingPath.removeLast() }
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            codingPath.append(ManyCodingKey(index: count))
            defer { codingPath.removeLast() }
            return UnkeyedContanier(encoder: encoder, codingPath: codingPath)
        }

        func superEncoder() -> Encoder {
            return encoder
        }
    }

    private class SingleValueContainer: SingleValueEncodingContainer {
        var encoder: ManyEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage
        var count: Int { return storage.count }

        init(encoder: ManyEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            storage = encoder.storage
        }

        func encodeNil() throws { storage.push(NSNull()) }
        func encode(_ value: Bool) throws { storage.push(value) }
        func encode(_ value: Int) throws { storage.push(value) }
        func encode(_ value: Int8) throws { storage.push(value) }
        func encode(_ value: Int16) throws { storage.push(value) }
        func encode(_ value: Int32) throws { storage.push(value) }
        func encode(_ value: Int64) throws { storage.push(value) }
        func encode(_ value: UInt) throws { storage.push(value) }
        func encode(_ value: UInt8) throws { storage.push(value) }
        func encode(_ value: UInt16) throws { storage.push(value) }
        func encode(_ value: UInt32) throws { storage.push(value) }
        func encode(_ value: UInt64) throws { storage.push(value) }
        func encode(_ value: Float) throws { storage.push(value) }
        func encode(_ value: Double) throws { storage.push(value) }
        func encode(_ value: String) throws { storage.push(value) }
        func encode<T: Encodable>(_ value: T) throws { storage.push(try encoder.box(value)) }
    }
}

open class ManyDecoder: Decoder {
    open var codingPath: [CodingKey]
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    fileprivate var storage = Storage()

    public init() {
        codingPath = []
    }

    public init(container: Any, codingPath: [CodingKey] = []) {
        storage.push(container)
        self.codingPath = codingPath
    }

    open func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = try lastContainer(forType: [String: Any].self)
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self, codingPath: [], container: try unboxRawType(container, as: [String: Any].self)))
    }

    open func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let container = try lastContainer(forType: [Any].self)
        return UnkeyedContanier(decoder: self, container: try unboxRawType(container, as: [Any].self))
    }

    open func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(decoder: self)
    }

    private func unboxRawType<T>(_ value: Any, as type: T.Type) throws -> T {
        return try cast(value, as: T.self)
    }

    private func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T {
        do {
            return try unboxRawType(value, as: T.self)
        } catch {
            storage.push(value)
            defer { storage.popContainer() }
            return try T(from: self)
        }
    }

    private func unwrap<T: Decodable>(_ item: Any, type: T.Type) throws -> T {
        do {
            var result: T
            switch (item, type) {
            case (let data as Data, is Data.Type):
                result = data as! T

            case (let string as String, is Data.Type):
                result = Data(hex: string) as! T

            case let (string as String, _):
                let data = string.data(using: .utf8) ?? Data()
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                result = try decode(type, from: json)

            case let (array as [Any], _):
                result = try decode(type, from: array)

            case let (dictionary as [String: Any], _):
                result = try decode(type, from: dictionary)

            default:
                throw DecodingError.mismatch(type)
            }
            return result
        } catch _ {
            do {
                storage.push(item)
                let result = try T(from: self)
                storage.popContainer()
                return result
            } catch {
                return try cast(nil, as: T.self)
            }
        }
    }

    private func lastContainer<T>(forType type: T.Type) throws -> Any {
        guard let value = storage.last else {
            let description = "Expected \(type) but found nil value instead."
            let error = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.valueNotFound(type, error)
        }
        return value
    }
}

extension ManyDecoder {
    public func decode<T: Decodable>(_ type: T.Type, from container: Any) throws -> T {
        return try unbox(container, as: T.self)
    }
}

extension ManyDecoder {
    private class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        private var decoder: ManyDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [String: Any]

        init(decoder: ManyDecoder, codingPath: [CodingKey], container: [String: Any]) {
            self.decoder = decoder
            self.codingPath = codingPath
            self.container = container
        }

        var allKeys: [Key] { return container.keys.compactMap { Key(stringValue: $0) } }
        func contains(_ key: Key) -> Bool { return container[key.stringValue] != nil }

        private func find(forKey key: CodingKey) throws -> Any {
            return container[key.stringValue] ?? ""
        }

        func _decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            let value = try find(forKey: key)
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try decoder.unbox(value, as: T.self)
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            guard let entry = container[key.stringValue] else {
                let error = DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\").")
                throw DecodingError.keyNotFound(key, error)
            }

            return entry is NSNull
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { return try _decode(type, forKey: key) }
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int { return try _decode(type, forKey: key) }
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { return try _decode(type, forKey: key) }
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { return try _decode(type, forKey: key) }
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { return try _decode(type, forKey: key) }
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { return try _decode(type, forKey: key) }
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return try _decode(type, forKey: key) }
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float { return try _decode(type, forKey: key) }
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return try _decode(type, forKey: key) }
        func decode(_ type: String.Type, forKey key: Key) throws -> String { return try _decode(type, forKey: key) }
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            let item = try find(forKey: key)
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try decoder.unwrap(item, type: T.self)
        }

        func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
            let item = try find(forKey: key)
            if let string = item as? String, string == "" { return nil }
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try decoder.unwrap(item, type: T.self)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            let dictionary = try decoder.unboxRawType(value, as: [String: Any].self)
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(decoder: decoder, codingPath: [], container: dictionary))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            let array = try decoder.unboxRawType(value, as: [Any].self)
            return UnkeyedContanier(decoder: decoder, container: array)
        }

        func _superDecoder(forKey key: CodingKey = ManyCodingKey.super) throws -> Decoder {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            return ManyDecoder(container: value, codingPath: decoder.codingPath)
        }

        func superDecoder() throws -> Decoder {
            return try _superDecoder()
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            return try _superDecoder(forKey: key)
        }
    }

    private class UnkeyedContanier: UnkeyedDecodingContainer {
        private var decoder: ManyDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [Any]

        var count: Int? { return container.count }
        var isAtEnd: Bool { return currentIndex >= count! }

        private(set) var currentIndex: Int
        private var currentCodingPath: [CodingKey] { return decoder.codingPath + [ManyCodingKey(index: currentIndex)] }

        init(decoder: ManyDecoder, container: [Any]) {
            self.decoder = decoder
            codingPath = decoder.codingPath
            self.container = container
            currentIndex = 0
        }

        private func checkIndex<T>(_ type: T.Type) throws {
            if isAtEnd {
                let error = DecodingError.Context(codingPath: currentCodingPath, debugDescription: "container is at end.")
                throw DecodingError.valueNotFound(T.self, error)
            }
        }

        func _decode<T: Decodable>(_ type: T.Type) throws -> T {
            try checkIndex(type)

            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer {
                decoder.codingPath.removeLast()
                currentIndex += 1
            }
            return try decoder.unbox(container[currentIndex], as: T.self)
        }

        func decodeNil() throws -> Bool {
            try checkIndex(Any?.self)

            if container[currentIndex] is NSNull {
                currentIndex += 1
                return true
            } else {
                return false
            }
        }

        func decode(_ type: Bool.Type) throws -> Bool { return try _decode(type) }
        func decode(_ type: Int.Type) throws -> Int { return try _decode(type) }
        func decode(_ type: Int8.Type) throws -> Int8 { return try _decode(type) }
        func decode(_ type: Int16.Type) throws -> Int16 { return try _decode(type) }
        func decode(_ type: Int32.Type) throws -> Int32 { return try _decode(type) }
        func decode(_ type: Int64.Type) throws -> Int64 { return try _decode(type) }
        func decode(_ type: UInt.Type) throws -> UInt { return try _decode(type) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { return try _decode(type) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try _decode(type) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try _decode(type) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try _decode(type) }
        func decode(_ type: Float.Type) throws -> Float { return try _decode(type) }
        func decode(_ type: Double.Type) throws -> Double { return try _decode(type) }
        func decode(_ type: String.Type) throws -> String { return try _decode(type) }
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try checkIndex(type)
            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer {
                decoder.codingPath.removeLast()
                currentIndex += 1
            }
            return try decoder.unwrap(container[currentIndex], type: type)
        }

        func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T: Decodable {
            try checkIndex(type)
            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer {
                decoder.codingPath.removeLast()
                currentIndex += 1
            }
            return try decoder.unwrap(container[currentIndex], type: type)
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            let dictionary = try cast(value, as: [String: Any].self)

            currentIndex += 1
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(decoder: decoder, codingPath: [], container: dictionary))
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            let array = try cast(value, as: [Any].self)

            currentIndex += 1
            return UnkeyedContanier(decoder: decoder, container: array)
        }

        func superDecoder() throws -> Decoder {
            decoder.codingPath.append(ManyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            currentIndex += 1
            return ManyDecoder(container: value, codingPath: decoder.codingPath)
        }
    }

    private class SingleValueContainer: SingleValueDecodingContainer {
        private var decoder: ManyDecoder
        private(set) var codingPath: [CodingKey]

        init(decoder: ManyDecoder) {
            self.decoder = decoder
            codingPath = decoder.codingPath
        }

        func _decode<T>(_ type: T.Type) throws -> T {
            let container = try decoder.lastContainer(forType: type)
            return try decoder.unboxRawType(container, as: T.self)
        }

        func decodeNil() -> Bool { return decoder.storage.last == nil }
        func decode(_ type: Bool.Type) throws -> Bool { return try _decode(type) }
        func decode(_ type: Int.Type) throws -> Int { return try _decode(type) }
        func decode(_ type: Int8.Type) throws -> Int8 { return try _decode(type) }
        func decode(_ type: Int16.Type) throws -> Int16 { return try _decode(type) }
        func decode(_ type: Int32.Type) throws -> Int32 { return try _decode(type) }
        func decode(_ type: Int64.Type) throws -> Int64 { return try _decode(type) }
        func decode(_ type: UInt.Type) throws -> UInt { return try _decode(type) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { return try _decode(type) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try _decode(type) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try _decode(type) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try _decode(type) }
        func decode(_ type: Float.Type) throws -> Float { return try _decode(type) }
        func decode(_ type: Double.Type) throws -> Double { return try _decode(type) }
        func decode(_ type: String.Type) throws -> String { return try _decode(type) }
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            return try decoder.unwrap(decoder.lastContainer(forType: type), type: type)
        }
    }
}

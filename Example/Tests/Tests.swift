import AnyCoder
import Runtime
import XCTest

struct Person: Codable, Equatable {
    enum Sex: String, Codable {
        case male = "m", female = "f"
    }

    var name: String
    var age: Int
    var id: Int64
    var sex: Sex
    var intro: String
    var data: Data?
    var date: Date
}

struct Event {
    var name: String
    var id: Int64
}

class User {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.password == rhs.password
            && lhs.person == rhs.person
    }

    var id: Int64
    var name: String
    var password: String?
    var person: Person?
    var list: [Int] = []
    var data: Data = Data()
    var date: Date = Date()
    var tuple1: (String, Int) = ("a", 1)
    var tuple2: (String, Int)? = ("a", 1)
    var tuple3: (String?, Int) = ("a", 1)
    var tuple4: (String?, Int?)? = ("a", 1)

    init(id: Int64 = 0, name: String = "", password: String? = nil, person: Person? = nil) {
        self.id = id
        self.name = name
        self.password = password
        self.person = person
    }
}

class Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoder() {
        let date = Date()
        let data = Data([0x31, 0x32, 0x33, 0x34, 0x35, 0xF, 0x41, 0x42, 0x43])
        var person: Person? = Person(name: "张三", age: 22, id: 1, sex: .female, intro: "哈哈哈哈", date: date)
        person?.data = data

        let user: User? = User(id: 2, name: "zhangsan")
        user?.list = [1, 2, 3, 4, 5]
        user?.data = data
        user?.person = person

        do {
            let dic_1 = try AnyEncoder.encode(person)
            let decoded_1 = try AnyDecoder.decode(Person?.self, from: dic_1)
            XCTAssert(person! == decoded_1!)
            let dic0 = try AnyEncoder.encode(user)
            let decoded0 = try AnyDecoder.decode(User?.self, from: dic0)
            XCTAssert(user != nil && decoded0 != nil && user! == decoded0!)
            let dic = try ManyEncoder().encode(person)
            let decoded = try ManyDecoder().decode(type(of: person), from: dic as Any)
            XCTAssertEqual(person, decoded)

            let dic1 = try ManyEncoder().encode(person)
            let decoded1 = try ManyDecoder().decode(type(of: person), from: dic1 as Any)
            XCTAssert(person != nil && decoded1 != nil && person! == decoded1!)

            let dic3 = try JSONEncoder().encode(person)
            let json3 = try JSONSerialization.jsonObject(with: dic3, options: [])
            let decoded3 = try JSONDecoder().decode(type(of: person), from: dic3)
            print(json3)
            XCTAssert(person != nil && decoded3 != nil && person! == decoded3!)

            let array2 = [person, nil]
            let dic2 = ManyEncoder().encode(array2)
            let decoded2 = try ManyDecoder().decode(type(of: array2), from: dic2 as Any)
            let person2 = decoded2.first!
            XCTAssert(decoded2.count == 2 && person! == person2!)
        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testAnyCoder() {
        do {
            let enuminfo = try typeInfo(of: Person.Sex.self)
            let tuple = (Data([0x1, 0x31, 0x61, 0x91]), 1, 2)
            let tupleinfo = try typeInfo(of: type(of: tuple))
            print(enuminfo)
            print(tupleinfo)
        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testPrimitive() {
        let a = "aaa"
        let b: Int? = 111
        let c: Bool = true
        do {
            let aa = try AnyEncoder.encode(a)
            let bb = try AnyEncoder.encode(b)
            let cc = try AnyEncoder.encode(c)
            print(aa)
            print(bb as Any)
            print(cc)
        } catch {
            print(error)
        }
    }
}

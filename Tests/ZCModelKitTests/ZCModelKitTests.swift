
import XCTest
@testable import ZCModelKit

final class ZCModelKitTests: XCTestCase {
    
    // MARK: - Test Models
    struct BasicUser: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    struct ResilientUser: Codable, Equatable {
        let userName: String
        let userAge: Int
        let isVip: Bool
        let email: String?
    }
    
    struct NestedModel: Codable, Equatable {
        let id: Int
        let info: Info
        struct Info: Codable, Equatable {
            let version: String
        }
    }
    
    // MARK: - Test Cases
    
    /// 1. 测试标准路径解析 (Happy Path)
    func testStandardPathDecoding() {
        let json = "{\"data\": {\"user\": {\"name\": \"ZClee\", \"age\": 25 }}}".data(using: .utf8)!
        XCTAssertNoThrow(try json.asDecodable(BasicUser.self, path: "data.user"))
        let user = try? json.asDecodable(BasicUser.self, path: "data.user")
        XCTAssertEqual(user?.name, "ZClee")
        XCTAssertEqual(user?.age, 25)
    }
    
    /// 2. 测试深层嵌套路径解析
    func testDeeplyNestedPath() {
        let json = "{\"a\": {\"b\": {\"c\": {\"id\": 1, \"info\": {\"version\": \"1.0\"} }}}}".data(using: .utf8)!
        XCTAssertNoThrow(try json.asDecodable(NestedModel.self, path: "a.b.c"))
        let model = try? json.asDecodable(NestedModel.self, path: "a.b.c")
        XCTAssertEqual(model?.id, 1)
        XCTAssertEqual(model?.info.version, "1.0")
    }
    
    /// 3. 测试类型强制转换: String -> Int (商用级鲁棒性)
    func testTypeCoercionStringToInt() {
        let json = "{\"user_name\": \"ZClee\", \"user_age\": \"25\", \"is_vip\": true, \"email\": \"test@test.com\"}".data(using: .utf8)!
        // 即使 age 是字符串 "25"，也应该能解析为 Int 25
        XCTAssertNoThrow(try json.asDecodable(ResilientUser.self))
        let user = try? json.asDecodable(ResilientUser.self)
        XCTAssertEqual(user?.userAge, 25)
    }
    
    /// 4. 测试命名风格自动转换 (snake_case -> camelCase)
    func testCaseConversion() {
        let json = "{\"user_name\": \"ZClee\", \"user_age\": 25, \"is_vip\": true, \"email\": \"test@test.com\"}".data(using: .utf8)!
        let user = try? json.asDecodable(ResilientUser.self)
        XCTAssertEqual(user?.userName, "ZClee")
    }
    
    /// 5. 测试可选字段缺失 (Optional Handling)
    func testMissingOptionalField() {
        let json = "{\"user_name\": \"ZClee\", \"user_age\": 25, \"is_vip\": true}".data(using: .utf8)! // email 缺失
        XCTAssertNoThrow(try json.asDecodable(ResilientUser.self))
        let user = try? json.asDecodable(ResilientUser.self)
        XCTAssertNil(user?.email)
    }
    
    /// 6. 测试非法路径 (Error Handling)
    func testInvalidPath() {
        let json = "{\"data\": {\"user\": {\"name\": \"ZClee\"}}}".data(using: .utf8)!
        XCTAssertThrowsError(try json.asDecodable(BasicUser.self, path: "data.wrong_path")) { error in
            XCTAssertTrue(error is ZCJSONError)
        }
    }
    
    /// 7. 测试损坏的 JSON (Invalid JSON)
    func testCorruptedJSON() {
        let json = "{ invalid json }".data(using: .utf8)!
        XCTAssertThrowsError(try json.asDecodable(BasicUser.self)) { error in
            XCTAssertTrue(error is ZCJSONError)
        }
    }
}

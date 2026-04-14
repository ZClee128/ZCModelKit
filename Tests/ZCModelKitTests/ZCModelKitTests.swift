import XCTest
@testable import ZCModelKit

class ZCModelKitTests: XCTestCase {
    struct User: Codable, Equatable {
        var name: String
        var age: Int
    }
    let json = "{\"data\": {\"user\": {\"name\": \"ZClee\", \"age\": 25 }}}".data(using: .utf8)!
    func testPathDecoding() {
        XCTAssertNoThrow(try json.asDecodable(User.self, path: "data.user"))
    }
    func testInvalidPath() {
        XCTAssertThrowsError(try json.asDecodable(User.self, path: "data.wrong"))
    }
}
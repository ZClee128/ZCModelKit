
import XCTest
@testable import ZCModelKit

final class ZCModelKitTests: XCTestCase {
    
    struct User: Codable, Equatable {
        var name: String
        var age: Int
    }
    
    let decoder = ZCJSONDecoder()
    let json = """
    {
        "api_data": {
            "user_info": {
                "full_name": "聪哥",
                "gender": "Male"
            }
        }
    }
    """.data(using: .utf8)!

    func testPathDecoding() {
        // Test if we can reach the nested object
        let mapping = ["name": "full_name", "age": "age"]
        let defaults = ["age": 18]
        let user = try? decoder.decode(User.self, from: json, path: "api_data.user_info", mapping: mapping, defaults: defaults)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.name, "聪哥")
        XCTAssertEqual(user?.age, 18)
    }
    
    func testDynamicMapping() {
        let mapping = ["name": "full_name"]
        let defaults = ["age": 20]
        let user = try? decoder.decode(User.self, from: json, path: "api_data.user_info", mapping: mapping, defaults: defaults)
        XCTAssertEqual(user?.name, "聪哥")
        XCTAssertEqual(user?.age, 20)
    }
    
    func testDefaultValues() {
        let defaults = ["age": 25]
        let user = try? decoder.decode(User.self, from: json, path: "api_data.user_info", defaults: defaults)
        // In this case, name will fail because no mapping is provided for 'full_name' -> 'name'
        // but we are testing the default logic
        XCTAssertNil(user) // Expect failure because name is missing
    }
}

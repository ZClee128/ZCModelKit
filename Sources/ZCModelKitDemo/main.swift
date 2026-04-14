
import Foundation
import ZCModelKit

// ======================================================================
// Test Models
// ======================================================================

struct User: Codable, Equatable {
    let name: String
    let age: Int
    let isVip: Bool
}

struct Product: Codable, Equatable {
    let title: String
    let price: Double
}

struct ComplexModel: Codable, Equatable {
    let id: Int
    let metadata: Meta
    struct Meta: Codable, Equatable {
        let version: String
    }
}

// ======================================================================
// Test Runner
// ======================================================================

func runTest(name: String, json: String, type: Any.Type, path: String? = nil, expected: Any? = nil) {
    print("🧪 Test: \(name)")
    let data = json.data(using: .utf8)!
    do {
        let result = try data.asDecodable(type, path: path)
        print("✅ Result: SUCCESS")
        if let expected = expected, let resultVal = result as? any Equatable {
            if String(describing: resultVal) == String(describing: expected) {
                print("🎯 Validation: MATCHED")
            } else {
                print("⚠️ Validation: MISMATCH (Got \(resultVal), expected \(expected))")
            }
        }
    } catch {
        print("❌ Result: FAILED (\(error))")
    }
    print("--------------------------------------------------")
}

print("\n🚀 --- ZCModelKit Commercial Grade Full Test Suite ---\n")

// Case 1: Standard Path Decoding (Happy Path)
runTest(
    name: "Standard Path Decoding",
    json: "{\"data\": {\"user\": {\"name\": \"ZClee\", \"age\": 25, \"is_vip\": true }}}",
    type: User.self,
    path: "data.user",
    expected: User(name: "ZClee", age: 25, isVip: true)
)

// Case 2: Deeply Nested Path
runTest(
    name: "Deeply Nested Path",
    json: "{\"a\": {\"b\": {\"c\": {\"id\": 1, \"metadata\": {\"version\": \"1.0\"} }}}}",
    type: ComplexModel.self,
    path: "a.b.c",
    expected: ComplexModel(id: 1, metadata: ComplexModel.Meta(version: "1.0"))
)

// Case 3: Type Coercion (String '25' -> Int 25)
// Note: This tests the ResilientDecoder implementation
runTest(
    name: "Type Coercion (String '25' -> Int 25)",
    json: "{\"name\": \"ZClee\", \"age\": \"25\", \"is_vip\": true}",
    type: User.self,
    expected: User(name: "ZClee", age: 25, isVip: true)
)

// Case 4: Case Conversion (snake_case -> camelCase)
runTest(
    name: "Snake Case -> Camel Case",
    json: "{\"user_name\": \"ZClee\", \"user_age\": 25, \"is_vip\": true}",
    type: User.self,
    expected: User(name: "ZClee", age: 25, isVip: true)
)

// Case 5: Invalid Path (Error Handling)
runTest(
    name: "Invalid Path Handling",
    json: "{\"data\": {\"user\": {\"name\": \"ZClee\"}}}",
    type: User.self,
    path: "data.wrong_path"
)

print("\n🏁 All Commercial Test Cases Executed.\n")

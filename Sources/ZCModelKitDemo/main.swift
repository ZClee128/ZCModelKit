import Foundation
import ZCModelKit

// --- Test Models ---

struct User: Codable, Equatable {
    let name: String
    let age: Int
    let isVip: Bool
    let score: Double
}

struct DeepModel: Codable, Equatable {
    struct Level1: Codable, Equatable {
        struct Level2: Codable, Equatable {
            let value: String
        }
        let level2: Level2
    }
    let level1: Level1
}

struct Company: Codable, Equatable {
    let companyName: String
    let employees: [User]
}

// --- Test Framework ---

func assertTest<T: Equatable>(name: String, json: String, type: T.Type, path: String? = nil, expected: T) {
    let data = json.data(using: .utf8)!
    do {
        let result = try data.zcDecode(T.self, path: path)
        if result == expected {
            print("✅ PASS: \(name)")
        } else {
            print("❌ FAIL: \(name) - Expected \(expected), got \(result)")
        }
    } catch {
        print("❌ FAIL: \(name) - Error: \(error)")
    }
}

func assertTestError<T: Decodable>(name: String, json: String, type: T.Type, path: String? = nil, expected: String) {
    let data = json.data(using: .utf8)!
    do {
        _ = try data.zcDecode(T.self, path: path)
        print("❌ FAIL: \(name) - Expected error \(expected), but succeeded")
    } catch {
        print("✅ PASS: \(name) - Caught expected error")
    }
}

// --- Ultimate Stress Test Suite ---

print("🚀 Starting ZCModelKit Extension-based Stress Test...\n")

// 1. Testing Data extension (Type Coercion)
let json1 = "{\"name\": \"ZC\", \"age\": \"25\", \"is_vip\": true, \"score\": 99.5}".data(using: .utf8)!
assertTest(name: "Data.zcDecode (Coercion)", json: String(data: json1, encoding: .utf8)!, type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))

// 2. Testing String extension (Deep Path)
let json2 = "{\"a\": {\"b\": {\"c\": {\"level1\": {\"level2\": {\"value\": \"OK\"}}}}}}"
assertTest(name: "String.zcDecode (Deep Path)", json: json2, type: DeepModel.self, path: "a.b.c", expected: DeepModel(level1: DeepModel.Level1(level2: DeepModel.Level1.Level2(value: "OK"))))

// 3. Testing Map (Dictionary) extension
let map: [String: Any] = ["company_name": "Apple", "employees": []]
do {
    let company = try map.zcDecode(Company.self)
    if company.companyName == "Apple" {
        print("✅ PASS: Map.zcDecode")
    } else {
        print("❌ FAIL: Map.zcDecode")
    }
} catch {
    print("❌ FAIL: Map.zcDecode - Error: \(error)")
}

// 4. Testing Array extension
let array: [Any] = [["name": "ZC", "age": "25", "is_vip": "true", "score": 100.0]]
do {
    let users = try array.zcDecode([User].self)
    if users.first?.name == "ZC" && users.first?.age == 25 {
        print("✅ PASS: Array.zcDecode")
    } else {
        print("❌ FAIL: Array.zcDecode")
    }
} catch {
    print("❌ FAIL: Array.zcDecode - Error: \(error)")
}

// 5. Edge Cases via String
assertTestError(name: "String.zcDecode (Invalid Path)", json: "{\"data\": {\"user\": \"ZC\"}}", type: User.self, path: "data.wrong", expected: "pathNotFound")
assertTestError(name: "String.zcDecode (Malformed)", json: "{ invalid }", type: User.self, expected: "invalidJSON")

print("\n🏁 Extension-based Stress Test Suite Completed.\n")

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
    let decoder = ZCJSONDecoder()
    let data = json.data(using: .utf8)!
    do {
        let result = try decoder.decode(T.self, from: data, path: path)
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
    let decoder = ZCJSONDecoder()
    let data = json.data(using: .utf8)!
    do {
        _ = try decoder.decode(T.self, from: data, path: path)
        print("❌ FAIL: \(name) - Expected error \(expected), but succeeded")
    } catch {
        print("✅ PASS: \(name) - Caught expected error")
    }
}

// --- Ultimate Stress Test Suite ---

print("🚀 Starting ZCModelKit Commercial-Grade Stress Test...\n")

// 1. Type Coercion
assertTest(name: "Coercion: String '25' -> Int", json: "{\"name\": \"ZC\", \"age\": \"25\", \"is_vip\": true, \"score\": 99.5}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
assertTest(name: "Coercion: String '99.5' -> Double", json: "{\"name\": \"ZC\", \"age\": 25, \"is_vip\": true, \"score\": \"99.5\"}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
assertTest(name: "Coercion: String 'true' -> Bool", json: "{\"name\": \"ZC\", \"age\": 25, \"is_vip\": \"true\", \"score\": 99.5}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))

// 2. Deep Path Navigation
assertTest(name: "Deep Path: a.b.c", json: "{\"a\": {\"b\": {\"c\": {\"level1\": {\"level2\": {\"value\": \"OK\"} } }}}", type: DeepModel.self, path: "a.b.c", expected: DeepModel(level1: DeepModel.Level1(level2: DeepModel.Level1.Level2(value: "OK"))))
assertTestError(name: "Invalid Path", json: "{\"data\": {\"user\": {\"name\": \"ZC\"}}}", type: User.self, path: "data.wrong", expected: "pathNotFound")

// 3. Case Conversion & Collections
assertTest(name: "SnakeCase -> CamelCase", json: "{\"company_name\": \"Apple\", \"employees\": []}", type: Company.self, expected: Company(companyName: "Apple", employees: []))
assertTest(name: "Array with Coercion", json: "{\"company_name\": \"Apple\", \"employees\": [{\"name\": \"A\", \"age\": \"20\", \"is_vip\": true, \"score\": 1.1}, {\"name\": \"B\", \"age\": \"30\", \"is_vip\": false, \"score\": 2.2}]}", type: Company.self, expected: Company(companyName: "Apple", employees: [User(name: "A", age: 20, isVip: true, score: 1.1), User(name: "B", age: 30, isVip: false, score: 2.2)]))

// 4. Edge Cases
assertTestError(name: "Empty Object", json: "{}", type: User.self, expected: "decodingError")
assertTestError(name: "Malformed JSON", json: "{ invalid }", type: User.self, expected: "invalidJSON")

print("\n🏁 Ultimate Stress Test Suite Completed.\n")

import Foundation

// ==========================================
// PART 1: ZCJSONDecoder (The Core Library)
// ==========================================

public class ZCJSONDecoder {
    public let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data, path: String? = nil) throws -> T {
        var currentData = data
        if let path = path {
            currentData = try navigateToPath(path, in: data)
        }
        let processedData = try preprocess(currentData)
        return try decoder.decode(T.self, from: processedData)
    }
    
    private func navigateToPath(_ path: String, in data: Data) throws -> Data {
        let components = path.components(separatedBy: ".")
        var currentJSON = try JSONSerialization.jsonObject(with: data, options: [])
        for component in components {
            if let dict = currentJSON as? [String: Any], let next = dict[component] {
                currentJSON = next
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Path not found: \(path)"))
            }
        }
        return try JSONSerialization.data(withJSONObject: currentJSON, options: [])
    }
    
    private func preprocess(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = jsonObject as? [String: Any] {
            let processedDict = try processDictionary(dict)
            return try JSONSerialization.data(withJSONObject: processedDict, options: [])
        } else if let array = jsonObject as? [Any] {
            let processedArray = try processArray(array)
            return try JSONSerialization.data(withJSONObject: processedArray, options: [])
        }
        return data
    }
    
    private func processDictionary(_ dict: [String: Any]) throws -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in dict {
            result[key] = try processValue(value)
        }
        return result
    }
    
    private func processArray(_ array: [Any]) throws -> [Any] {
        return try array.map { try processValue($0) }
    }
    
    private func processValue(_ value: Any) throws -> Any {
        if let dict = value as? [String: Any] {
            return try processDictionary(dict)
        } else if let array = value as? [Any] {
            return try processArray(array)
        } else if let string = value as? String {
            if string.lowercased() == "true" { return true }
            if string.lowercased() == "false" { return false }
            if let intVal = Int(string) { return intVal }
            if let doubleVal = Double(string) { return doubleVal }
        }
        return value
    }
}

// ==========================================
// PART 2: Stress Test Suite
// ==========================================

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

func assertTest<T: Decodable & Equatable>(name: String, json: String, type: T.Type, path: String? = nil, expected: T) {
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

print("🚀 Starting ZCModelKit Standalone Stress Test...\n")

assertTest(name: "Coercion: String '25' -> Int", json: "{\"name\": \"ZC\", \"age\": \"25\", \"is_vip\": true, \"score\": 99.5}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
assertTest(name: "Coercion: String '99.5' -> Double", json: "{\"name\": \"ZC\", \"age\": 25, \"is_vip\": true, \"score\": \"99.5\"}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
assertTest(name: "Coercion: String 'true' -> Bool", json: "{\"name\": \"ZC\", \"age\": 25, \"is_vip\": \"true\", \"score\": 99.5}", type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
assertTest(name: "Deep Path: a.b.c", json: "{\"a\": {\"b\": {\"c\": {\"level1\": {\"level2\": {\"value\": \"OK\"}}}}}}", type: DeepModel.self, path: "a.b.c", expected: DeepModel(level1: DeepModel.Level1(level2: DeepModel.Level1.Level2(value: "OK"))))
assertTestError(name: "Invalid Path", json: "{\"data\": {\"user\": {\"name\": \"ZC\"}}}", type: User.self, path: "data.wrong", expected: "pathNotFound")
assertTest(name: "SnakeCase -> CamelCase", json: "{\"company_name\": \"Apple\", \"employees\": []}", type: Company.self, expected: Company(companyName: "Apple", employees: []))
assertTest(name: "Array with Coercion", json: "{\"company_name\": \"Apple\", \"employees\": [{\"name\": \"A\", \"age\": \"20\", \"is_vip\": true, \"score\": 1.1}, {\"name\": \"B\", \"age\": \"30\", \"is_vip\": false, \"score\": 2.2}]}", type: Company.self, expected: Company(companyName: "Apple", employees: [User(name: "A", age: 20, isVip: true, score: 1.1), User(name: "B", age: 30, isVip: false, score: 2.2)]))
assertTestError(name: "Empty Object", json: "{}", type: User.self, expected: "decodingError")
assertTestError(name: "Malformed JSON", json: "{ invalid }", type: User.self, expected: "invalidJSON")

print("\n🏁 Standalone Stress Test Suite Completed.\n")

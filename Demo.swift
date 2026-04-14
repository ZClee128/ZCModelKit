import Foundation

// ==========================================
// PART 1: ZCJSONDecoder (The Core Library)
// ==========================================

public class ZCJSONDecoder {
    public static let shared = ZCJSONDecoder()
    
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
    
    public func decode<T: Decodable>(_ type: T.Type, from object: Any, path: String? = nil) throws -> T {
        var currentObject = object
        if let path = path {
            currentObject = try navigateToObject(path, in: object)
        }
        let processedObject = try processValue(currentObject)
        let data = try JSONSerialization.data(withJSONObject: processedObject, options: [])
        return try decoder.decode(T.self, from: data)
    }
    
    private func navigateToPath(_ path: String, in data: Data) throws -> Data {
        let object = try navigateToObject(path, in: try JSONSerialization.jsonObject(with: data, options: []))
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }
    
    private func navigateToObject(_ path: String, in object: Any) throws -> Any {
        let components = path.components(separatedBy: ".")
        var current = object
        for component in components {
            if let dict = current as? [String: Any], let next = dict[component] {
                current = next
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Path not found: \(path)"))
            }
        }
        return current
    }
    
    private func preprocess(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let processed = try processValue(jsonObject)
        return try JSONSerialization.data(withJSONObject: processed, options: [])
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
}

extension Data {
    public func zcDecode<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        return try ZCJSONDecoder.shared.decode(type, from: self, path: path)
    }
}

extension String {
    public func zcDecode<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        guard let data = self.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid UTF8 string"))
        }
        return try data.zcDecode(type, path: path)
    }
}

extension Dictionary where Key == String, Value == Any {
    public func zcDecode<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        return try ZCJSONDecoder.shared.decode(type, from: self, path: path)
    }
}

extension Array where Element == Any {
    public func zcDecode<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        return try ZCJSONDecoder.shared.decode(type, from: self, path: path)
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

print("🚀 Starting ZCModelKit Standalone Extension-based Stress Test...\n")

let json1 = "{\"name\": \"ZC\", \"age\": \"25\", \"is_vip\": true, \"score\": 99.5}".data(using: .utf8)!
assertTest(name: "Data.zcDecode (Coercion)", json: String(data: json1, encoding: .utf8)!, type: User.self, expected: User(name: "ZC", age: 25, isVip: true, score: 99.5))
let json2 = "{\"a\": {\"b\": {\"c\": {\"level1\": {\"level2\": {\"value\": \"OK\"}}}}}}"
assertTest(name: "String.zcDecode (Deep Path)", json: json2, type: DeepModel.self, path: "a.b.c", expected: DeepModel(level1: DeepModel.Level1(level2: DeepModel.Level1.Level2(value: "OK"))))

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

let array: [Any] = [["name\": \"ZC\", \"age\": \"25\", \"is_vip\": \"true\", \"score\": 100.0]]
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

assertTestError(name: "String.zcDecode (Invalid Path)", json: "{\"data\": {\"user\": \"ZC\"}}", type: User.self, path: "data.wrong", expected: "pathNotFound")
assertTestError(name: "String.zcDecode (Malformed)", json: "{ invalid }", type: User.self, expected: "invalidJSON")

print("\n🏁 Standalone Extension-based Stress Test Suite Completed.\n")

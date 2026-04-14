
import Foundation

// --- ZCModelKit implementation (Simplified for standalone demo) ---
public enum ZCJSONError: Error {
    case invalidJSON
    case pathNotFound(String)
    case decodingError(Error)
}

public extension Data {
    func asDecodable<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []) else {
            throw ZCJSONError.invalidJSON
        }
        
        var currentObject: Any = jsonObject
        if let path = path {
            let components = path.components(separatedBy: ".")
            for component in components {
                if let dict = currentObject as? [String: Any], let next = dict[component] {
                    currentObject = next
                } else {
                    throw ZCJSONError.pathNotFound(path)
                }
            }
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let targetData = try JSONSerialization.data(withJSONObject: currentObject, options: [])
            return try decoder.decode(T.self, from: targetData)
        } catch {
            throw ZCJSONError.decodingError(error)
        }
    }
}

// --- Demo Section ---

// 1. Define a clean Codable model
struct UserProfile: Codable {
    let userName: String
    let userAge: Int
    let email: String
}

// 2. A complex JSON response
let jsonString = """
{
    "status": "success",
    "data": {
        "user": {
            "user_name": "ZClee",
            "user_age": 25,
            "email": "zclee@example.com"
        },
        "config": {
            "theme": "dark",
            "notifications": true
        }
    }
}
"""
let jsonData = jsonString.data(using: .utf8)!

print("--- ZCModelKit Demo ---\n")

do {
    // Magic: Extract UserProfile from path "data.user"
    // Note: user_name in JSON becomes userName in model automatically thanks to .convertFromSnakeCase
    let user = try jsonData.asDecodable(UserProfile.self, path: "data.user")
    print("✅ Successfully decoded user!")
    print("Name: \(user.userName)")
    print("Age: \(user.userAge)")
    print("Email: \(user.email)\n")
    
} catch {
    print("❌ Decoding failed: \(error)")
}

// Test Case: Invalid Path
do {
    _ = try jsonData.asDecodable(UserProfile.self, path: "data.wrong_path")
} catch {
    print("✅ Caught expected error: \(error)")
}

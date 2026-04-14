import Foundation
import ZCModelKit

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

import Foundation
import ZCModelKit

struct UserProfile: Codable {
    let userName: String
    let userAge: Int
    let email: String
}

let jsonString = "{\"status\": \"success\", \"data\": {\"user\": {\"user_name\": \"ZClee\", \"user_age\": 25, \"email\": \"zclee@example.com\" }}}"
let jsonData = jsonString.data(using: .utf8)!

print("\n--- 🚀 ZCModelKit Live Demo ---\n")
try? { 
    let user = try jsonData.asDecodable(UserProfile.self, path: "data.user")
    print("✅ Successfully decoded user!")
    print("👤 Name: \(user.userName)")
    print("🎂 Age: \(user.userAge)")
    print("📧 Email: \(user.email)\n")
}()
print("--- Demo Finished ---\n")
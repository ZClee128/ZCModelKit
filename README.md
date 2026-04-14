# ZCModelKit 🚀

**ZCModelKit** is a commercial-grade Swift JSON parsing library designed for absolute resilience and zero-configuration. It empowers developers to handle "dirty" API responses with a pure `Codable` approach, removing the need for manual mapping or fragile macros.

## 💎 Core Philosophy

- **Zero-Configuration**: Works out-of-the-box with standard `Codable` models.
- **Zero-Intrusion**: Your models remain pure Swift structs; no annotations or proprietary macros required.
- **Maximum Resilience**: Automatically handles type coercion (e.g., String "123" $\rightarrow$ Int 123) and missing fields without crashing the entire object decoding.
- **Path-Based Decoding**: Extract deeply nested objects using simple dot-notation paths.

## 🚀 Key Features

- **Type Coercion**: Seamlessly converts `String` to `Int`, `Double`, and `Bool`.
- **Path Navigation**: `decoder.decode(User.self, from: data, path: "data.user.profile")`.
- **Resilient Arrays**: Decodes lists of objects even if some fields in the JSON are type-mismatched.
- **Automatic Case Conversion**: Built-in support for `snake_case` to `camelCase` conversion.

## 🛠 Quick Start

```swift
let decoder = ZCJSONDecoder()
let json = "{\"user_name\": \"ZClee\", \"age\": \"25\"}".data(using: .utf8)!

// Pure Codable model
struct User: Codable {
    let userName: String
    let age: Int
}

let user = try decoder.decode(User.self, from: json)
print(user.age) // 25 (Automatically coerced from String to Int)
```

## 🧪 Commercial Stress Test

The library is tested against the following high-risk scenarios:
- Deeply nested path navigation.
- String-to-Numeric type coercion.
- String-to-Boolean coercion.
- Malformed JSON and empty objects.
- Mixed-type arrays in commercial APIs.

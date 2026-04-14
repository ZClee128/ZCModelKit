# ZCModelKit 📦

ZCModelKit is a lightweight, zero-intrusion JSON decoding library for Swift. It allows you to handle complex JSON structures, custom key mappings, and default values without ever modifying your `Codable` models.

## ✨ Key Features

- **Zero Intrusion**: No macros, no annotations. Your models remain pure `Codable`.
- **Path Navigation**: Decode nested objects directly using dot-notation paths (e.g., `"data.user.profile"`).
- **Dynamic Mapping**: Map JSON keys to model properties at runtime.
- **Default Values**: Inject default values for missing fields dynamically.

## 🚀 Quick Start

### Installation
Add `ZCModelKit` to your project via Swift Package Manager:
`https://github.com/ZClee128/ZCModelKit`

### Usage

```swift
struct User: Codable {
    var name: String
    var age: Int
}

let decoder = ZCJSONDecoder()
let json = ... // Your JSON Data

let user = try decoder.decode(
    User.self, 
    from: json, 
    path: "api_data.user", 
    mapping: ["name": "full_name"], 
    defaults: ["age": 18]
)
```

## 🛠 How it Works
ZCModelKit acts as a preprocessing layer. It navigates to the target JSON path, translates the keys based on your mapping, injects default values, and then hands the "cleaned" data to the native `JSONDecoder`. This ensures 100% compatibility with Swift's `Codable` system while removing all the boilerplate.

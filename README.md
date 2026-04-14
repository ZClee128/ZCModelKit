# ZCModelKit 🚀

A lightweight, zero-configuration JSON decoding utility for Swift.

## 🌟 Philosophy
**No Annotations. No Mapping. Just Decodable.**

ZCModelKit allows you to extract and decode models from complex JSON structures using simple path strings, without modifying your models or writing tedious `CodingKeys`.

## 📦 Installation
Add the following package to your project:
`https://github.com/ZClee128/ZCModelKit`

## 🚀 Quick Start

```swift
struct User: Codable {
    var name: String
    var age: Int
}

let json = """
{
    "api": {
        "data": {
            "user": {
                "name": "ZClee",
                "age": 25
            }
        }
    }
}""".data(using: .utf8)!

// Just one line to get your model from any path!
do {
    let user = try json.asDecodable(User.self, path: "api.data.user")
    print("Hello, \(user.name)!")
} catch {
    print("Decoding failed: \(error)")
}
```

## ✨ Features
- **Path-based Navigation**: Extract models from any nested level using dot-notation (`"a.b.c"`).
- **Zero Intrusion**: Works with any standard `Codable` type. No macros, no annotations.
- **Smart Conversion**: Automatically handles `snake_case` to `camelCase` conversion.
- **Ultra Lightweight**: Zero dependencies, minimal overhead.


## 🧪 Demo
Check out [Demo.swift](Demo.swift) for a complete runnable example!\n\n## 🛠 How to Run Demo\n\nYou can run the demo directly from the terminal without any Xcode setup:\n\n1. Clone the repo:\n`git clone https://github.com/ZClee128/ZCModelKit.git`\n2. Enter the directory:\n`cd ZCModelKit`\n3. Run the demo:\n`swift run ZCModelKitDemo`

## 🛡️ Commercial Grade Features

ZCModelKit is designed for production environments where API stability cannot be guaranteed.

### 1. Type Coercion (Intelligent Casting)
Stop worrying about typeMismatch errors. ZCModelKit automatically coerces types:
- String '123' -> Int 123
- Int 1 -> Bool true
- Any type -> String

### 2. Resilient Decoding
Unlike standard JSONDecoder which fails the entire object if one field is wrong, ZCModelKit handles errors gracefully.

### 3. Zero-Configuration
No macros, no annotations, no CodingKeys. Just pure Codable models and a path string.
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
Check out [Demo.swift](Demo.swift) for a complete runnable example!
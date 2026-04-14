import Foundation

/// ZCJSONDecoder: A commercial-grade, resilient JSON decoder for Swift.
/// Philosophy: Zero-Configuration, Zero-Intrusion, and Maximum Resilience.
public class ZCJSONDecoder {
    public static let shared = ZCJSONDecoder()
    
    public let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Decodes a type from the given data, optionally navigating to a specific path.
    public func decode<T: Decodable>(_ type: T.Type, from data: Data, path: String? = nil) throws -> T {
        var currentData = data
        
        if let path = path {
            currentData = try navigateToPath(path, in: data)
        }
        
        let processedData = try preprocess(currentData)
        return try decoder.decode(T.self, from: processedData)
    }
    
    /// Overload to decode directly from a JSON-compatible object (Map or Array)
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

// ==========================================
// API Extensions for "Dot-Syntax" Decoding
// ==========================================

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

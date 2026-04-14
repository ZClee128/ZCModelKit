import Foundation

/// ZCJSONDecoder: A commercial-grade, resilient JSON decoder for Swift.
/// Philosophy: Zero-Configuration, Zero-Intrusion, and Maximum Resilience.
public class ZCJSONDecoder {
    public let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        // Default to convert snake_case to camelCase to increase resilience
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

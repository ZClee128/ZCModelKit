
import Foundation

/// ZCModelKit: A zero-intrusion JSON decoding library.
/// Allows dynamic key mapping and default values without modifying the Codable models.
public class ZCJSONDecoder {
    public init() {}
    
    /// Decodes a type from data with optional path navigation, key mapping, and default values.
    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        path: String? = nil,
        mapping: [String: String] = [:],
        defaults: [String: Any] = [:]
    ) throws -> T {
        // 1. Parse root JSON into a dictionary
        guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Root JSON is not a dictionary"))
        }
        
        // 2. Path Navigation: Navigate to the target nested object
        if let path = path {
            let components = path.components(separatedBy: ".")
            for component in components {
                if let next = json[component] as? [String: Any] {
                    json = next
                } else {
                    throw DecodingError.keyNotFound(DynamicKey.self, .init(codingPath: [], debugDescription: "Path component '\(component)' not found in path \(path)"))
                }
            }
        }
        
        // 3. Apply Dynamic Mapping and Defaults
        // We create a new dictionary where keys are translated to match the model's property names
        var processedDict = [String: Any]()
        
        // First, fill in all available values from the JSON based on mapping
        // The mapping is [ModelProperty : JSONKey]
        for (modelKey, jsonKey) in mapping {
            if let value = json[jsonKey] {
                processedDict[modelKey] = value
            }
        }
        
        // Also add values from the JSON that don't have a mapping (direct match)
        for (jsonKey, value) in json {
            if !mapping.values.contains(jsonKey) {
                processedDict[jsonKey] = value
            }
        }
        
        // Finally, inject default values for missing keys
        for (modelKey, defaultValue) in defaults {
            if processedDict[modelKey] == nil {
                processedDict[modelKey] = defaultValue
            }
        }
        
        // 4. Convert the processed dictionary back to Data and use standard JSONDecoder
        let finalData = try JSONSerialization.data(withJSONObject: processedDict, options: [])
        return try JSONDecoder().decode(T.self, from: finalData)
    }
}

// Internal helper for error reporting
struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { return nil }
}

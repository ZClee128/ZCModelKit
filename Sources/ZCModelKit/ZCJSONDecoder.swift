import Foundation

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
        let processedObject = preprocess(currentObject)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let targetData = try JSONSerialization.data(withJSONObject: processedObject, options: [])
            return try decoder.decode(T.self, from: targetData)
        } catch {
            throw ZCJSONError.decodingError(error)
        }
    }
    private func preprocess(_ object: Any) -> Any {
        if let dict = object as? [String: Any] {
            var newDict = [String: Any]()
            for (key, value) in dict { newDict[key] = preprocess(value) }
            return newDict
        } else if let array = object as? [Any] {
            return array.map { preprocess($0) }
        } else if let string = object as? String {
            if let i = Int(string) { return i }
            if let d = Double(string) { return d }
            if string.lowercased() == "true" { return true }
            if string.lowercased() == "false" { return false }
            return string
        }
        return object
    }
}
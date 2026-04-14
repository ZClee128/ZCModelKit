
import Foundation

public enum ZCJSONError: Error {
    case invalidJSON
    case pathNotFound(String)
    case decodingError(Error)
}

public extension Data {
    /// 解析指定路径下的 JSON 为指定模型
    /// - Parameters:
    ///   - type: 目标模型类型 (需遵循 Codable)
    ///   - path: JSON 路径, 例如 "data.user.profile"
    /// - Returns: 解析后的模型对象
    func asDecodable<T: Decodable>(_ type: T.Type, path: String? = nil) throws -> T {
        // 1. 将 Data 解析为基础字典/数组
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []) else {
            throw ZCJSONError.invalidJSON
        }
        
        // 2. 路径导航
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
        
        // 3. 使用原生 JSONDecoder 解析目标片段
        // 开启 convertFromSnakeCase 以支持常见的下划线转驼峰
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let targetData = try JSONSerialization.data(withJSONObject: currentObject, options: [])
            return try decoder.decode(T.self, from: targetData)
        } catch {
            throw ZCJSONError.decodingError(error)
        }
    }
}

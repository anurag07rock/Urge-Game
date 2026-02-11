import Foundation

final class PersistenceService: @unchecked Sendable {
    static let shared = PersistenceService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func save<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = defaults.data(forKey: key) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(type, from: data) {
                return decoded
            }
        }
        return nil
    }
    
    func clear(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding_v3") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding_v3") }
    }
}

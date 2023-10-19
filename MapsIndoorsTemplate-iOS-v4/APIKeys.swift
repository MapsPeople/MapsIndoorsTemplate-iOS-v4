import Foundation

struct APIKeys {
    
    private static let keys: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict
        }
        return nil
    }()
    
    static let googleMapsAPIKey: String = {
        return (keys?["GoogleMapsAPIKey"] as? String ?? ProcessInfo.processInfo.environment["GOOGLE_API_KEY"]) ?? "GOOGLE_API_KEY"
    }()
    
    static let mapboxAPIKey: String = {
        return (keys?["MapboxAPIKey"] as? String ?? ProcessInfo.processInfo.environment["MAPBOX_API_KEY"]) ?? "MAPBOX_API_KEY"
    }()
}

import SwiftUI
import CoreLocation
import MapsIndoors

class UserLocation: MPLocation {
    var aliases: [String]
    var baseType: MapsIndoors.MPLocationBaseType
    var building: String?
    var categories: [String]
    var coordinateBounds: MapsIndoors.MPGeoBounds?
    var externalId: String?
    var floorIndex: NSNumber
    var floorName: String
    var icon: UIImage?
    var iconUrl: URL?
    var imageURL: String?
    var isBookable: Bool
    var locationDescription: String?
    var locationId: String
    var geometry: MapsIndoors.MPGeometry?
    var name: String
    var position: MapsIndoors.MPPoint
    var fields: [String : MapsIndoors.MPLocationField]
    var restrictions: [String]?
    var type: String
    var venue: String?
    var entityPosition: MapsIndoors.MPPoint
    var entityBounds: MapsIndoors.MPGeoBounds
    var entityIsPoint: Bool
    
    init(name: String, position: CLLocationCoordinate2D) {
        self.aliases = ["userPosition", "blueDot"]
        self.baseType = .pointOfInterest
        self.building = "N/A"
        self.categories = ["N/A"]
        self.coordinateBounds = nil
        self.externalId = "N/A"
        self.floorIndex = 1
        self.floorName = "N/A"
        self.icon = nil
        self.iconUrl = nil
        self.imageURL = nil
        self.isBookable = false
        self.locationDescription = "My Location"
        self.locationId = "N/A"
        self.geometry = nil
        self.name = name
        self.position = MPPoint(coordinate: position)
        self.fields = [:]
        self.restrictions = nil
        self.type = "N/A"
        self.venue = "N/A"
        self.entityPosition = MPPoint(coordinate: position)
        
        let delta = 0.001
        let southWest = CLLocationCoordinate2D(latitude: position.latitude - delta, longitude: position.longitude - delta)
        let northEast = CLLocationCoordinate2D(latitude: position.latitude + delta, longitude: position.longitude + delta)
        let geoBounds = MPGeoBounds(southWest: southWest, northEast: northEast)

        self.entityBounds = geoBounds
        self.entityIsPoint = true
    }

    func getLiveValue(forKey key: String, domainType: String) -> AnyObject? {
        // not needed
        return nil
    }
    
    func getLiveUpdate(forDomainType domainType: String) -> MapsIndoors.MPLiveUpdate? {
        // not needed
        return nil
    }
    
    func property(key: String) -> MapsIndoors.MPLocationField? {
        // not needed
        return nil
    }
}

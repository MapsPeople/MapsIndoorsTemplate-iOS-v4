import Foundation
import CoreLocation
import MapsIndoors

class CoreLocationPositionProvider: NSObject, MPPositionProvider, CLLocationManagerDelegate {
    
    var delegate: MPPositionProviderDelegate?
    var latestPosition: MPPositionResult?
    let locationManager = CLLocationManager()
    
    var lastKnownGroundAltitude: Double?
    var lastKnownCoordinate: CLLocationCoordinate2D?
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startPositioning() {
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = 5 // Get updates every 5 degrees change
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let position = MPPositionResult(coordinate: location.coordinate, accuracy: location.horizontalAccuracy, bearing: latestPosition?.bearing ?? 0)
            
            // Check if we're within the threshold of the last known coordinate
            if let lastCoord = lastKnownCoordinate, location.distance(from: CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)) < 100 {
                // Use the saved ground altitude
                if let savedAltitude = lastKnownGroundAltitude {
                    //print("Using saved ground altitude: \(savedAltitude) meters above sea level")
                }
            } else {
                // Fetch new ground altitude
                fetchGroundLevelAltitude(latitude: position.coordinate.latitude, longitude: position.coordinate.longitude) { (elevation, error) in
                    if let elevation = elevation {
                        //print("Ground level altitude: \(elevation) meters above sea level")
                        self.lastKnownGroundAltitude = elevation
                        self.lastKnownCoordinate = location.coordinate
                    } else if let error = error {
                        print("Error fetching altitude: \(error.localizedDescription)")
                    }
                }
            }
            
            let altitude = location.altitude
            //print("Altitude: \(altitude) meters above sea level")
            
            if let groundAltitude = lastKnownGroundAltitude {
                let altitudeDifference = altitude - groundAltitude
                let averageFloorHeight = 3.0 // meters
                let estimatedFloorLevel = Int(altitudeDifference / averageFloorHeight) + 1
                //print("Estimated floor level: \(estimatedFloorLevel)")
                position.floorIndex = estimatedFloorLevel * 10
            }
            
            latestPosition = position
            delegate?.onPositionUpdate(position: position)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if let latestPosition = self.latestPosition {
            let updatedPosition = MPPositionResult(coordinate: latestPosition.coordinate, floorIndex: latestPosition.floorIndex, accuracy: latestPosition.accuracy, bearing: newHeading.trueHeading)
            self.latestPosition = updatedPosition
            delegate?.onPositionUpdate(position: updatedPosition)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: break
            // Do nothing, we've just requested the authorization
        case .restricted, .denied:
            // Handle the case where the user has denied or restricted location access.
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func fetchGroundLevelAltitude(latitude: Double, longitude: Double, completion: @escaping (Double?, Error?) -> Void) {
        // Construct the URL
        let urlString = "https://api.opentopodata.org/v1/eudem25m?locations=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }
        
        // Create the URLSession task
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Handle errors
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Parse the response data
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let elevation = results.first?["elevation"] as? Double {
                        completion(elevation, nil)
                    } else {
                        completion(nil, NSError(domain: "InvalidJSON", code: -2, userInfo: nil))
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
        
        // Start the task
        task.resume()
    }
}

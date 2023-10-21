//  MapView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors
import MapsIndoorsGoogleMaps
import GoogleMaps
import MapsIndoorsMapbox
import MapboxMaps
import MapboxGeocoder

struct MapsIndoorsView: UIViewRepresentable {
    let mapsIndoorsKey = "d876ff0e60bb430b8fabb145"
    var onMapsIndoorsLoaded: (([MPBuilding], [MPLocation], MPMapControl?) -> Void)?
    var onLocationSelected: ((MPLocation?) -> Void)?
    var onUserPositionUpdate: ((MPLocation?, Bool) -> Void)?

    func makeUIView(context: Context) -> UIView {
        let mapEngine = MapType.mapbox
        
        switch mapEngine {
        case .googleMaps:
            // Set up the Google Maps view. Centered around The White House.
            let camera = GMSCameraPosition.camera(withLatitude: 38.8977, longitude: -77.0365, zoom: 10)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            
            Task {
                do {
                    // Load MapsIndoors with the MapsIndoors API key.
                    try await MPMapsIndoors.shared.load(apiKey: mapsIndoorsKey)
                    
                    // Initialize the MPMapConfig with the GMSMapView.
                    let mapConfig = MPMapConfig(gmsMapView: mapView, googleApiKey: APIKeys.googleMapsAPIKey)
                    let mapControl = MPMapsIndoors.createMapControl(mapConfig: mapConfig)
                    
                    // Set the coordinator as the delegate
                    context.coordinator.control = mapControl
                    mapControl?.delegate = context.coordinator
                    
                    // Setup positioning
                    context.coordinator.setupPositionProvider()
                    mapControl?.showUserPosition = true
                    
                    context.coordinator.gmsMapView = mapView
                    
                    // Fetch all the locations and buildings in the solution
                    let locations = await MPMapsIndoors.shared.locationsWith(query: MPQuery(), filter: MPFilter())
                    let buildings = await MPMapsIndoors.shared.buildings()
                    // Select a building from the solution to focus camera on it
                    mapControl?.select(building: buildings.first, behavior: .default)
                    // Notify that MapsIndoors has loaded and return buildings
                    onMapsIndoorsLoaded?(buildings, locations, mapControl)
                } catch {
                    print("Error loading MapsIndoors: \(error.localizedDescription)")
                }
            }
            return mapView
        case .mapbox:
            let myResourceOptions = ResourceOptions(accessToken: APIKeys.mapboxAPIKey)
            let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, styleURI: .light)
            let mapView = MapView(frame: CGRect.zero, mapInitOptions: myMapInitOptions)
            
            Task {
                do {
                    // Load MapsIndoors with the MapsIndoors API key.
                    try await MPMapsIndoors.shared.load(apiKey: mapsIndoorsKey)
                    // Initialize the MPMapConfig with the GMSMapView.
                    let mapConfig = MPMapConfig(mapBoxView: mapView, accessToken: APIKeys.mapboxAPIKey)
                    let mapControl = MPMapsIndoors.createMapControl(mapConfig: mapConfig)
                    
                    // Set the coordinator as the delegate
                    context.coordinator.control = mapControl
                    mapControl?.delegate = context.coordinator
                    
                    // Setup positioning
                    context.coordinator.setupPositionProvider()
                    mapControl?.showUserPosition = true
                    
                    context.coordinator.mbMapView = mapView
                    
                    // Fetch all the locations and buildings in the solution
                    let locations = await MPMapsIndoors.shared.locationsWith(query: MPQuery(), filter: MPFilter())
                    let buildings = await MPMapsIndoors.shared.buildings()
                    // Select a building from the solution to focus camera on it
                    mapControl?.select(building: buildings.first, behavior: .default)
                    // Notify that MapsIndoors has loaded and return buildings
                    onMapsIndoorsLoaded?(buildings, locations, mapControl)
                } catch {
                    print("Error loading MapsIndoors: \(error.localizedDescription)")
                }
            }
            return mapView
        }
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MapsIndoorsView>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(nil, parent: self)
    }
    
    // MARK: - Coordinator Class
    class Coordinator: NSObject, MPMapControlDelegate, CLLocationManagerDelegate {
        var control: MPMapControl?
        var parent: MapsIndoorsView
        var positionProvider: CoreLocationPositionProvider?
        var gmsMapView: GMSMapView?
        var mbMapView: MapView?
        
        var lastKnownStreetName: String = "N/A"
        var lastKnownCoordinate: CLLocationCoordinate2D?
        
        var currentMapType: MapType {
            if gmsMapView != nil {
                return .googleMaps
            } else {
                return .mapbox
            }
        }
        
        init(_ control: MPMapControl?, parent: MapsIndoorsView) {
            self.control = control
            self.parent = parent
            super.init()
        }
        
        // MARK: Positioning
        func setupPositionProvider() {
            positionProvider = CoreLocationPositionProvider()
            positionProvider?.setupLocationManager()
            MPMapsIndoors.shared.positionProvider = positionProvider
            positionProvider?.startPositioning()
        }
        
        func isCoordinateVisibleOnMap(coordinate: CLLocationCoordinate2D, mapView: GMSMapView) -> Bool {
            let visibleRegion = mapView.projection.visibleRegion()
            let bounds = GMSCoordinateBounds(region: visibleRegion)
            return bounds.contains(coordinate)
        }
        
        func isCoordinateVisibleOnMap(coordinate: CLLocationCoordinate2D, mapView: MapView) -> Bool {
            return mapView.bounds.contains(mapView.mapboxMap.point(for: coordinate))
        }
        
        func googleReverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
                if let address = response?.firstResult(), let streetName = address.thoroughfare {
                    completion(streetName)
                } else {
                    completion("N/A")
                }
            }
        }
        
        func mapboxReverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
            let geocoder = Geocoder(accessToken: APIKeys.mapboxAPIKey)
            let options = ReverseGeocodeOptions(coordinate: coordinate)
            
            geocoder.geocode(options) { (placemarks, attribution, error) in
                if let placemark = placemarks?.first {
                    completion(placemark.name)
                } else {
                    completion("N/A")
                }
            }
        }
        
        func shouldReverseGeocode(newCoordinate: CLLocationCoordinate2D) -> Bool {
            guard let lastCoordinate = lastKnownCoordinate else {
                return true
            }
            let distance = newCoordinate.distance(from: lastCoordinate)
            // Check if the distance is more than 50 meters (or any threshold you prefer)
            return distance > 50.0
        }
        
        func updateUserPosition(position: MPPositionResult) {
            let reverseGeocodeFunction: (CLLocationCoordinate2D, @escaping (String) -> Void) -> Void
            let mapView: UIView
            
            switch currentMapType {
            case .googleMaps:
                reverseGeocodeFunction = googleReverseGeocode
                mapView = gmsMapView!
            case .mapbox:
                reverseGeocodeFunction = mapboxReverseGeocode
                mapView = mbMapView!
            }
            
            if shouldReverseGeocode(newCoordinate: position.coordinate) {
                reverseGeocodeFunction(position.coordinate) { [self] streetName in
                    self.lastKnownStreetName = streetName
                    self.lastKnownCoordinate = position.coordinate
                    let userLocation = UserLocation(name: "Current Location", position: position.coordinate, building: streetName)
                    if let gmsMapView = mapView as? GMSMapView {
                        parent.onUserPositionUpdate?(userLocation, isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: gmsMapView))
                    } else if let mbMapView = mapView as? MapView {
                        parent.onUserPositionUpdate?(userLocation, isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: mbMapView))
                    }
                }
            } else {
                let userLocation = UserLocation(name: "Current Location", position: position.coordinate, building: lastKnownStreetName)
                if let gmsMapView = mapView as? GMSMapView {
                    parent.onUserPositionUpdate?(userLocation, isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: gmsMapView))
                } else if let mbMapView = mapView as? MapView {
                    parent.onUserPositionUpdate?(userLocation, isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: mbMapView))
                }
            }
        }
        
        // MARK: MPMapControlDelegate methods
        func didChange(selectedLocation: MapsIndoors.MPLocation?) -> Bool {
            parent.onLocationSelected?(selectedLocation)
            return false
        }
        
        func onPositionUpdate(position: MPPositionResult) {
            updateUserPosition(position: position)
        }
    }
}

enum MapType {
    case googleMaps
    case mapbox
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

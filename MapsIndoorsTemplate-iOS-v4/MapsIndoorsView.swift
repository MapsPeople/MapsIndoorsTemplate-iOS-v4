//  MapView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors
import MapsIndoorsGoogleMaps
import GoogleMaps
import MapsIndoorsMapbox
import MapboxMaps

struct MapsIndoorsView: UIViewRepresentable {
    let mapsIndoorsKey = "d876ff0e60bb430b8fabb145"
    var onMapsIndoorsLoaded: (([MPBuilding], [MPLocation], MPMapControl?) -> Void)?
    var onLocationSelected: ((MPLocation?) -> Void)?
    var onUserPositionUpdate: ((MPLocation?, Bool) -> Void)?

    func makeUIView(context: Context) -> UIView {
        let mapEngine = MapEngine.googleMaps
        
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
    
    class Coordinator: NSObject, MPMapControlDelegate, CLLocationManagerDelegate {
        var control: MPMapControl?
        var parent: MapsIndoorsView
        var positionProvider: CoreLocationPositionProvider?
        var gmsMapView: GMSMapView?
        var mbMapView: MapView?
        
        init(_ control: MPMapControl?, parent: MapsIndoorsView) {
            self.control = control
            self.parent = parent
            super.init()
        }
        
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
        
        // MPMapControlDelegate method
        func didChange(selectedLocation: MapsIndoors.MPLocation?) -> Bool {
            parent.onLocationSelected?(selectedLocation)
            return false
        }
        
        func onPositionUpdate(position: MPPositionResult) {
            if let usingGoogleMapsView = gmsMapView {
                parent.onUserPositionUpdate?(UserLocation(name: "Current_Location", position: position.coordinate), isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: usingGoogleMapsView))
            }
            if let usingMapboxView = mbMapView {
                parent.onUserPositionUpdate?(UserLocation(name: "Current_Location", position: position.coordinate), isCoordinateVisibleOnMap(coordinate: position.coordinate, mapView: usingMapboxView))
            }
            
        }
    }
}

enum MapEngine {
    case googleMaps
    case mapbox
}

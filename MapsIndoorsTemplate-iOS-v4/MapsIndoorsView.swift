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
    
    class Coordinator: NSObject, MPMapControlDelegate {
        var control: MPMapControl?
        var parent: MapsIndoorsView
        
        init(_ control: MPMapControl?, parent: MapsIndoorsView) {
            self.control = control
            self.parent = parent
        }
        
        func didChange(selectedLocation: MapsIndoors.MPLocation?) -> Bool {
            parent.onLocationSelected?(selectedLocation)
            return false
        }
    }
}

enum MapEngine {
    case googleMaps
    case mapbox
}

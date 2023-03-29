//  MapView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoorsGoogleMaps
import GoogleMaps

struct MapView: UIViewRepresentable {
    @Binding var searchResult: [IdentifiableLocation]?
    @Binding var origin: MPLocation?
    @Binding var mpMapControl: MPMapControl?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 38.8977, longitude: -77.0365, zoom: 20)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // Initialize the MPMapConfig with the GMSMapView
        let mapConfig = MPMapConfig(gmsMapView: mapView, googleApiKey: "YOUR_GOOGLE_API_KEY")
        
        Task {
            do {
                // Load MapsIndoors with the MapsIndoors API key
                try await MPMapsIndoors.shared.load(apiKey: "d876ff0e60bb430b8fabb145") // Test API
                
                if let mapControl = MPMapsIndoors.createMapControl(mapConfig: mapConfig) {
                    // Retain the mapControl object
                    mpMapControl = mapControl
                    
                    let query = MPQuery()
                    let filter = MPFilter()
                    
                    query.query = "Family Dining Room"
                    filter.take = 1
                    
                    let locations = await MPMapsIndoors.shared.locationsWith(query: query, filter: filter)
                    if let firstLocation = locations.first {
                        mapControl.select(location: firstLocation, behavior: .default)
                        mapControl.select(floorIndex: firstLocation.floorIndex.intValue)
                        // Set the origin as Family Dining room
                        origin = firstLocation
                    }
                }
                
            } catch {
                print("Error loading MapsIndoors: \(error.localizedDescription)")
            }
        }
        
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update your map view here
    }
    
    class Coordinator: NSObject {
        var mapView: MapView
        
        init(_ mapView: MapView) {
            self.mapView = mapView
        }
    }
}

//  MapView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors
import MapsIndoorsGoogleMaps
import GoogleMaps

struct MapsIndoorsView: UIViewRepresentable {
    func makeUIView(context: Context) -> GMSMapView {
        // Set up the Google Maps view. Centered on The White House.
        let camera = GMSCameraPosition.camera(withLatitude: 38.8977, longitude: -77.0365, zoom: 10)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        Task {
            do {
                // Load MapsIndoors with the MapsIndoors API key.
                try await MPMapsIndoors.shared.load(apiKey: "d876ff0e60bb430b8fabb145")
                // Initialize the MPMapConfig with the GMSMapView.
                let mapConfig = MPMapConfig(gmsMapView: mapView, googleApiKey: APIKeys.googleMapsAPIKey)
                let mapControl = MPMapsIndoors.createMapControl(mapConfig: mapConfig)
                await mapControl?.select(building: MPMapsIndoors.shared.buildings().first, behavior: .default)
            } catch {
                print("Error loading MapsIndoors: \(error.localizedDescription)")
            }
        }
        
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: UIViewRepresentableContext<MapsIndoorsView>) {
        // Update the map view if needed
    }
}

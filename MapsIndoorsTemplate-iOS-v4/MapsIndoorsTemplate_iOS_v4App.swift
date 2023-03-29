//  MapsIndoorsTemplate_iOS_v4App.swift
import SwiftUI
import GoogleMaps

@main
struct MapsIndoorsTemplate_iOS_v4App: App {
    init() {
        GMSServices.provideAPIKey("YOUR_GOOGLE_API_KEY")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

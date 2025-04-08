//  MapsIndoorsTemplate_iOS_v4App.swift
import SwiftUI

@main
struct MapsIndoorsTemplate_iOS_v4App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // TODO: Temporary measure
        }
    }
}

//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoorsGoogleMaps
import GoogleMaps

struct ContentView: View {
    @State private var searchResult: [MPLocation]?
    @State private var origin: MPLocation?
    @State private var mpMapControl: MPMapControl?

    var body: some View {
        NavigationView {
            ZStack {
                MapView(searchResult: $searchResult, origin: $origin, mpMapControl: $mpMapControl)
                    .edgesIgnoringSafeArea(.all)

                // Add your search bar and other UI components here
            }
            .navigationBarTitle("MapsIndoors v4 SwiftUI", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

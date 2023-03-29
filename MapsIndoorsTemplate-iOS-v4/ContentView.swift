//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoorsGoogleMaps
import GoogleMaps

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResult: [IdentifiableLocation]?
    @State private var origin: MPLocation?
    @State private var mpMapControl: MPMapControl?

    var body: some View {
        NavigationView {
            ZStack {
                MapView(searchResult: $searchResult, origin: $origin, mpMapControl: $mpMapControl)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    SearchBar(text: $searchText, onTextDidChange: searchLocations)
                    
                    if let searchResult = searchResult {
                        LocationList(locations: searchResult) { location in
                            didSelect(location: location)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitle("MapsIndoors v4 SwiftUI Template", displayMode: .inline)
        }
    }

    func searchLocations(_ searchText: String) {
        let query = MPQuery()
        let filter = MPFilter()
        query.query = searchText
        filter.take = 100
        Task {
            let locations = await MPMapsIndoors.shared.locationsWith(query: query, filter: filter)
            let identifiableLocations = locations.map { IdentifiableLocation(location: $0) }
            searchResult = identifiableLocations
        }
    }

    func didSelect(location: MPLocation) {
        mpMapControl?.goTo(entity: location)
        searchResult = nil
    }
}

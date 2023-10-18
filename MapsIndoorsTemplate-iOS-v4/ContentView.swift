//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors

struct ContentView: View {
    @State private var isMapsIndoorsLoaded = false
    @State private var searchText = ""
    @State private var buildings: [MPBuilding] = []
    @State private var filteredBuildings: [MPBuilding] = []
    @State private var locations: [MPLocation] = []
    @State private var filteredLocations: [MPLocation] = []
    @State private var mapControl: MPMapControl?
    var body: some View {
        VStack {
            if isMapsIndoorsLoaded {
                SearchBar(text: $searchText)
                    .padding()
                if !filteredBuildings.isEmpty || !filteredLocations.isEmpty {
                    List {
                        ForEach(filteredBuildings, id: \.buildingId) { building in
                            Button(action: {
                                Task {
                                    mapControl?.select(building: building, behavior: .default)
                                }
                                searchText = ""  // Clear the search text
                            }) {
                                VStack(alignment: .leading) {
                                    Text(building.name!)
                                        .font(.headline)
                                    if let address = building.address {
                                        Text(address)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        ForEach(filteredLocations, id: \.locationId) { location in
                            Button(action: {
                                Task {
                                    mapControl?.select(location: location, behavior: .default)
                                }
                                searchText = ""  // Clear the search text
                            }) {
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .font(.headline)
                                    if let buildingName = location.building {
                                        Text(buildingName)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            MapsIndoorsView { loadedBuildings, loadedLocations, control in
                isMapsIndoorsLoaded = true
                buildings = loadedBuildings
                locations = loadedLocations
                mapControl = control
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: searchText) { _ in
            filterSearchData()
        }
    }

    func filterSearchData() {
        if searchText.isEmpty {
            filteredBuildings = []
            filteredLocations = []
        } else {
            filteredBuildings = buildings.filter {
                $0.name!.lowercased().contains(searchText.lowercased())
            }
            filteredLocations = locations.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

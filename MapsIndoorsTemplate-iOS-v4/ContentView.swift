//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors

struct ContentView: View {
    @State private var isMapsIndoorsLoaded = false
    @State private var searchText = ""
    @State private var buildings: [MPBuilding] = []
    @State private var filteredBuildings: [MPBuilding] = []
    @State private var mapControl: MPMapControl?
    var body: some View {
        VStack {
            if isMapsIndoorsLoaded {
                SearchBar(text: $searchText)
                    .padding()
                if !filteredBuildings.isEmpty {
                    List(filteredBuildings, id: \.buildingId) { building in
                        Button(action: {
                            Task {
                                mapControl?.select(building: building, behavior: .default)
                            }
                            searchText = ""  // Clear the search text
                        }) {
                            Text(building.name!)
                        }
                    }
                }
            }
            MapsIndoorsView { loadedBuildings, control in
                isMapsIndoorsLoaded = true
                buildings = loadedBuildings
                mapControl = control
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: searchText) { _ in
            filterBuildings()
        }
    }

    func filterBuildings() {
        if searchText.isEmpty {
            filteredBuildings = []
        } else {
            filteredBuildings = buildings.filter {
                $0.name!.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

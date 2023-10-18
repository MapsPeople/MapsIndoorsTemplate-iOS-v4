//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors

struct ContentView: View {
    @ObservedObject var viewModel = MapsIndoorsViewModel()

    var body: some View {
        VStack {
            if viewModel.isMapsIndoorsLoaded {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                if !viewModel.filteredBuildings.isEmpty || !viewModel.filteredLocations.isEmpty {
                    List {
                        ForEach(viewModel.filteredBuildings, id: \.buildingId) { building in
                            BuildingRowView(building: building) {
                                Task {
                                    viewModel.mapControl?.select(building: building, behavior: .default)
                                }
                                viewModel.searchText = ""  // Clear the search text
                            }
                        }
                        ForEach(viewModel.filteredLocations, id: \.locationId) { location in
                            LocationRowView(location: location) {
                                Task {
                                    viewModel.mapControl?.select(location: location, behavior: .default)
                                }
                                viewModel.searchText = ""  // Clear the search text
                            }
                        }
                    }
                }
            }
            MapsIndoorsView { loadedBuildings, loadedLocations, control in
                viewModel.isMapsIndoorsLoaded = true
                viewModel.buildings = loadedBuildings
                viewModel.locations = loadedLocations
                viewModel.mapControl = control
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.filterSearchData()
        }
    }
}

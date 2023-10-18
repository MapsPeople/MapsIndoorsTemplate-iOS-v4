//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors

struct ContentView: View {
    @ObservedObject var viewModel = MapsIndoorsViewModel()
    @State private var showingDetailPanel = false
    @State private var showingDirectionsPanel = false
    @State private var selectedLocation: MPLocation?

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
                                selectedLocation = location
                                showingDetailPanel = true
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
        if showingDetailPanel {
            LocationDetailPanel(location: selectedLocation, isPresented: $showingDetailPanel) {
                showingDetailPanel = false
                showingDirectionsPanel = true
            }
            .transition(.move(edge: .bottom))
            .animation(.default)
        }
        
        if showingDirectionsPanel {
            DirectionsPanel(viewModel: DirectionsPanelViewModel(location: selectedLocation, allLocations: viewModel.locations, mapControl: viewModel.mapControl!), isPresented: $showingDirectionsPanel)
                .transition(.move(edge: .bottom))
                .animation(.default)
        }
    }
}

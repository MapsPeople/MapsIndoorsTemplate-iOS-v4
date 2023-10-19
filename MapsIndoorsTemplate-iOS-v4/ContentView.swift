//  ContentView.swift
import SwiftUI
import MapsIndoorsCore
import MapsIndoors

struct ContentView: View {
    @ObservedObject var viewModel = MapsIndoorsViewModel()
    @State private var showingDetailPanel = false
    @State private var showingDirectionsPanel = false
    @State private var selectedLocation: MPLocation?
    @State private var showingSidePanelContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
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
                // Side Panel
                if showingSidePanelContent {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Button(action: {
                                showingSidePanelContent.toggle()
                            }) {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                        Text("Primary Text")
                            .font(.title)
                            .padding(.top)
                        
                        Button(action: {
                            showingSidePanelContent.toggle()
                        }) {
                            Text("Open View")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .frame(width: 200)
                    .shadow(radius: 10)
                    .offset(x: showingSidePanelContent ? 0 : -geometry.size.width)
                    .animation(.default)
                }
                // LocationDetailPanel
                if showingDetailPanel {
                    VStack {
                        Spacer()
                        LocationDetailPanel(location: selectedLocation, isPresented: $showingDetailPanel) {
                            showingDetailPanel = false
                            showingDirectionsPanel = true
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.default)
                    }
                }
                // DirectionsPanel
                if showingDirectionsPanel {
                    VStack {
                        Spacer()
                        DirectionsPanel(viewModel: DirectionsPanelViewModel(location: selectedLocation, allLocations: viewModel.locations, mapControl: viewModel.mapControl!), isPresented: $showingDirectionsPanel)
                            .transition(.move(edge: .bottom))
                            .animation(.default)
                    }
                }
                // Button with Icon
                if viewModel.isMapsIndoorsLoaded && !showingSidePanelContent {
                    VStack(alignment: .leading) {
                        Button(action: {
                            showingSidePanelContent.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading + 10)
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                }
            }
        }
    }
}

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
                MainContent(viewModel: viewModel, selectedLocation: $selectedLocation, showingDetailPanel: $showingDetailPanel)
                SidePanel(showingSidePanelContent: $showingSidePanelContent, geometry: geometry, viewModel: viewModel)
                LocationDetailPanelView(showingDetailPanel: $showingDetailPanel, showingDirectionsPanel: $showingDirectionsPanel, selectedLocation: selectedLocation)
                DirectionsPanelView(showingDirectionsPanel: $showingDirectionsPanel, selectedLocation: selectedLocation, viewModel: viewModel)
                SidePanelToggleButton(viewModel: viewModel, showingSidePanelContent: $showingSidePanelContent, geometry: geometry)
            }
        }
    }
}
// MARK: - Main Content
struct MainContent: View {
    @ObservedObject var viewModel: MapsIndoorsViewModel
    @Binding var selectedLocation: MPLocation?
    @Binding var showingDetailPanel: Bool
    
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
    }
}

// MARK: - Side Panel
struct SidePanel: View {
    @Binding var showingSidePanelContent: Bool
    var geometry: GeometryProxy
    @ObservedObject var viewModel: MapsIndoorsViewModel

    var body: some View {
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
                Text("Buildings")
                    .font(.title)
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.buildings, id: \.name) { building in
                            Button(action: {
                                viewModel.mapControl?.select(building: building, behavior: .default)
                            }) {
                                Text(building.name ?? "")
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                .frame(maxHeight: 300)

                Spacer()
            }
            .padding()
            .background(Color.white)
            .frame(width: 200)
            .shadow(radius: 10)
            .offset(x: showingSidePanelContent ? 0 : -geometry.size.width)
            .animation(.default)
        }
    }
}

// MARK: - Location Detail Panel View
struct LocationDetailPanelView: View {
    @Binding var showingDetailPanel: Bool
    @Binding var showingDirectionsPanel: Bool
    var selectedLocation: MPLocation?
    
    var body: some View {
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
    }
}

// MARK: - Directions Panel View
struct DirectionsPanelView: View {
    @Binding var showingDirectionsPanel: Bool
    var selectedLocation: MPLocation?
    @ObservedObject var viewModel: MapsIndoorsViewModel
    
    var body: some View {
        if showingDirectionsPanel {
            VStack {
                Spacer()
                DirectionsPanel(viewModel: DirectionsPanelViewModel(location: selectedLocation, allLocations: viewModel.locations, mapControl: viewModel.mapControl!), isPresented: $showingDirectionsPanel)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
        }
    }
}

// MARK: - Side Panel Toggle Button
struct SidePanelToggleButton: View {
    @ObservedObject var viewModel: MapsIndoorsViewModel
    @Binding var showingSidePanelContent: Bool
    var geometry: GeometryProxy
    
    var body: some View {
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

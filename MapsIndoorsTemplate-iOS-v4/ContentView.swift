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
    @State private var isRouteRendered: Bool = false
    @State private var renderedRoute: MPRoute?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                MapsIndoorsView(onMapsIndoorsLoaded: { loadedBuildings, loadedLocations, control in
                    viewModel.isMapsIndoorsLoaded = true
                    viewModel.buildings = loadedBuildings
                    viewModel.locations = loadedLocations
                    viewModel.mapControl = control
                }, onLocationSelected: { location in
                    viewModel.selectedLocationChanged = location
                    viewModel.locationDidChange.toggle()
                })
                SearchContent(viewModel: viewModel, selectedLocation: $selectedLocation, showingDetailPanel: $showingDetailPanel)
                SidePanel(showingSidePanelContent: $showingSidePanelContent, geometry: geometry, viewModel: viewModel)
                LocationDetailPanelView(showingDetailPanel: $showingDetailPanel, showingDirectionsPanel: $showingDirectionsPanel, selectedLocation: selectedLocation)
                DirectionsPanelView(showingDirectionsPanel: $showingDirectionsPanel, selectedLocation: selectedLocation, viewModel: viewModel, isRouteRendered: $isRouteRendered, renderedRoute: $renderedRoute)
                SidePanelToggleButton(viewModel: viewModel, showingSidePanelContent: $showingSidePanelContent, showingDirectionsPanel: $showingDirectionsPanel, geometry: geometry)
            }
            .onChange(of: viewModel.locationDidChange) { _ in
                selectedLocation = viewModel.selectedLocationChanged
                showingDetailPanel = viewModel.selectedLocationChanged != nil
            }
            if isRouteRendered {
                RouteRenderedPanel(route: renderedRoute)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                    .offset(y: geometry.size.height * 0.75)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
        }
    }
}
// MARK: - Main Content
struct SearchContent: View {
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
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.filterSearchData()
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
                .animation(.default, value: showingDetailPanel)
            }
        }
    }
}

// MARK: - Directions Panel View
struct DirectionsPanelView: View {
    @Binding var showingDirectionsPanel: Bool
    var selectedLocation: MPLocation?
    @ObservedObject var viewModel: MapsIndoorsViewModel
    @Binding var isRouteRendered: Bool
    @Binding var renderedRoute: MPRoute?

    var body: some View {
        if showingDirectionsPanel {
            VStack {
                Spacer()
                DirectionsPanel(viewModel: DirectionsPanelViewModel(location: selectedLocation, allLocations: viewModel.locations, mapControl: viewModel.mapControl!, isRouteRendered: $isRouteRendered, renderedRoute: $renderedRoute), isPresented: $showingDirectionsPanel)
                    .transition(.move(edge: .bottom))
                    .animation(.default, value: showingDirectionsPanel)
            }
        }
    }
}

// MARK: - Side Panel Toggle Button
struct SidePanelToggleButton: View {
    @ObservedObject var viewModel: MapsIndoorsViewModel
    @Binding var showingSidePanelContent: Bool
    @Binding var showingDirectionsPanel: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        if viewModel.isMapsIndoorsLoaded && !showingSidePanelContent && !showingDirectionsPanel {
            VStack(alignment: .leading) {
                Button(action: {
                    showingSidePanelContent.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(0.8)
                }
                Spacer()
            }
            .padding(.leading, geometry.safeAreaInsets.leading + 10)
            .padding(.top, geometry.safeAreaInsets.top + 30)
        }
    }
}

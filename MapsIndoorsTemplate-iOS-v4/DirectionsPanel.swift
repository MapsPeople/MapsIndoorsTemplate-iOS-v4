import SwiftUI
import MapsIndoors
import MapsIndoorsCore

struct DirectionsPanel: View {
    @ObservedObject var viewModel: DirectionsPanelViewModel
    @Binding var isPresented: Bool
    
    var originSearchTextBinding: Binding<String> {
        Binding(
            get: { self.viewModel.originSearchText },
            set: { self.viewModel.originSearchText = $0 }
        )
    }
    
    var destinationSearchTextBinding: Binding<String> {
        Binding(
            get: { self.viewModel.destinationSearchText },
            set: { self.viewModel.destinationSearchText = $0 }
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Directions to \(viewModel.location?.name ?? "Destination")")
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Origin")
                    .font(.headline)
                SearchBar(text: originSearchTextBinding)
                    .onChange(of: viewModel.originSearchText) { newValue in
                        viewModel.originSearchResults = viewModel.allLocations.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                List(viewModel.originSearchResults, id: \.locationId) { loc in
                    Button(action: {
                        viewModel.originSearchText = loc.name
                        viewModel.selectedOrigin = loc
                        viewModel.originSearchResults = []
                        viewModel.generateRouteIfPossible()
                    }) {
                        Text(loc.name)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Destination")
                    .font(.headline)
                SearchBar(text: destinationSearchTextBinding)
                    .onChange(of: viewModel.destinationSearchText) { newValue in
                        viewModel.destinationSearchResults = viewModel.allLocations.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                List(viewModel.destinationSearchResults, id: \.locationId) { loc in
                    Button(action: {
                        viewModel.destinationSearchText = loc.name
                        viewModel.selectedDestination = loc
                        viewModel.destinationSearchResults = []
                        viewModel.generateRouteIfPossible()
                    }) {
                        Text(loc.name)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .frame(height: 700)
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding()
            }, alignment: .topTrailing
        )
        .onReceive(viewModel.$isRouteRendered) { isRendered in
            if isRendered {
                isPresented = false
                viewModel.isRouteRenderedBinding?.wrappedValue = true
            }
        }
        .onAppear {
            viewModel.destinationSearchText = viewModel.location?.name ?? ""
            viewModel.selectedDestination = viewModel.location
        }
    }
}

class DirectionsPanelViewModel: ObservableObject {
    var location: MPLocation?
    var allLocations: [MPLocation]
    var mapControl: MPMapControl

    @Published var originSearchText: String = ""
    @Published var destinationSearchText: String = ""
    @Published var originSearchResults: [MPLocation] = []
    @Published var destinationSearchResults: [MPLocation] = []
    @Published var selectedOrigin: MPLocation?
    @Published var selectedDestination: MPLocation?
    
    @Published var isRouteRendered: Bool = false
    var isRouteRenderedBinding: Binding<Bool>?
    
    var renderedRoute: Binding<MPRoute?>?

    var directionsRenderer: MPDirectionsRenderer?

    init(location: MPLocation?, allLocations: [MPLocation], mapControl: MPMapControl, isRouteRendered: Binding<Bool>?, renderedRoute: Binding<MPRoute?>) {
        self.location = location
        self.allLocations = allLocations
        self.mapControl = mapControl
        self.isRouteRenderedBinding = isRouteRendered
        self.renderedRoute = renderedRoute
    }

    func generateRouteIfPossible() {
        if let origin = selectedOrigin, let destination = selectedDestination {
            Task {
                await directions(to: destination, from: origin)
            }
        }
    }

    func directions(to destination: MPLocation, from origin: MPLocation) async {
        if directionsRenderer == nil {
            directionsRenderer = mapControl.newDirectionsRenderer()
        }
        let directionsQuery = MPDirectionsQuery(origin: origin, destination: destination)

        do {
            let route = try await MPMapsIndoors.shared.directionsService.routingWith(query: directionsQuery)
            directionsRenderer?.route = route
            directionsRenderer?.routeLegIndex = 0
            DispatchQueue.main.async {
                self.directionsRenderer?.animate(duration: 5)
                self.isRouteRendered = true
                self.renderedRoute?.wrappedValue = route
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

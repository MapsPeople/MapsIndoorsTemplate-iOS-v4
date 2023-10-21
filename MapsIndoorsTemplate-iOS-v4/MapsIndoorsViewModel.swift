import SwiftUI
import MapsIndoors

class MapsIndoorsViewModel: ObservableObject {
    @Published var isMapsIndoorsLoaded = false
    @Published var buildings: [MPBuilding] = []
    @Published var locations: [MPLocation] = []

    // For MPMapControl Delegate methods
    @Published var locationDidChange: Bool = false
    @Published var selectedLocationChanged: MPLocation?
    
    var mapControl: MPMapControl?

    
}

class SearchContentViewModel: ObservableObject {
    @Published var viewModel: MapsIndoorsViewModel
    @Published var searchText = ""
    @Published var filteredLocations: [MPLocation] = []
    @Published var filteredBuildings: [MPBuilding] = []
    
    init(viewModel: MapsIndoorsViewModel) {
        self.viewModel = viewModel
    }
    
    func filterSearchData() {
        if searchText.isEmpty {
            filteredBuildings = []
            filteredLocations = []
        } else {
            filteredBuildings = viewModel.buildings.filter {
                $0.name!.lowercased().contains(searchText.lowercased())
            }
            filteredLocations = viewModel.locations.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

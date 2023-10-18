import SwiftUI
import MapsIndoors

class MapsIndoorsViewModel: ObservableObject {
    @Published var isMapsIndoorsLoaded = false
    @Published var searchText = ""
    @Published var buildings: [MPBuilding] = []
    @Published var filteredBuildings: [MPBuilding] = []
    @Published var locations: [MPLocation] = []
    @Published var filteredLocations: [MPLocation] = []
    
    // Use a regular property for mapControl
    var mapControl: MPMapControl?

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

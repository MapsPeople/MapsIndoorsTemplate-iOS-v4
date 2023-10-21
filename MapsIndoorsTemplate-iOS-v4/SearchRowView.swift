import SwiftUI
import MapsIndoors

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

struct BuildingRowView: View {
    let building: MPBuilding
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(building.name!)
                    .font(.headline)
                if let address = building.address {
                    Text("Address: " + address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("This is a Building")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct LocationRowView: View {
    let location: MPLocation
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                if let buildingName = location.building {
                    Text("Building: " + buildingName + " Floor: " + location.floorIndex.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("This is a Location")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

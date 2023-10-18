import SwiftUI
import MapsIndoors

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
                    Text("In Building: " + buildingName)
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

import SwiftUI
import MapsIndoors

struct LocationDetailPanel: View {
    var location: MPLocation?

    var body: some View {
        VStack {
            if let location = location {
                Text(location.name)
                    .font(.title)
                    .padding()

                if let buildingName = location.building {
                    Text("In Building: \(buildingName)")
                        .font(.subheadline)
                        .padding(.bottom)
                }

                Text("Floor Index: \(location.floorIndex)")
                    .font(.subheadline)
                    .padding(.bottom)

                Text("Location Type: \(location.type)")
                        .font(.subheadline)
                        .padding(.bottom)
                
                Text("Is Bookable: \(location.isBookable ? "Yes" : "No")")
                    .font(.subheadline)
                    .padding(.bottom)

                Button("Directions") {
                    // Handle routing and directions here
                }
                .padding()
            } else {
                Text("No location selected.")
            }
        }
        .padding()
    }
}

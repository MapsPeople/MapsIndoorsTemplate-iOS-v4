import SwiftUI
import MapsIndoors

struct LocationDetailPanel: View {
    var location: MPLocation?
    @Binding var isPresented: Bool
    var showDirections: () -> Void
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
                    showDirections()
                }
                .padding()
                
                Spacer() // Pushes the content to the top
            } else {
                Text("No location selected.")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding()
            }, alignment: .topTrailing
        )
    }
}

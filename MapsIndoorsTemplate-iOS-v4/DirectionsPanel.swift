import SwiftUI
import MapsIndoors

struct DirectionsPanel: View {
    var location: MPLocation?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Directions to \(location?.name ?? "Destination")")
                .font(.title)
                .padding()
            
            // Add your directions or routing UI here
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity)
        .frame(height: 400) // Adjust as needed
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

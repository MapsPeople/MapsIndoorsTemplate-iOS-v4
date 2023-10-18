import SwiftUI
import MapsIndoors

struct DirectionsPanel: View {
    var location: MPLocation?
    @Binding var isPresented: Bool
    
    @State private var originSearchText: String = ""
    @State private var destinationSearchText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Directions to \(location?.name ?? "Destination")")
                .font(.title)
                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                .minimumScaleFactor(0.5)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Origin")
                    .font(.headline)
                SearchBar(text: $originSearchText)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Destination")
                    .font(.headline)
                SearchBar(text: $destinationSearchText)
                    .disabled(true) // Disable editing as this will be pre-filled
            }
            
            Spacer()
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
        .onAppear {
            destinationSearchText = location?.name ?? ""
        }
    }
}

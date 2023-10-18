import SwiftUI
import MapsIndoors

struct DirectionsPanel: View {
    var location: MPLocation?
    var allLocations: [MPLocation]
    @Binding var isPresented: Bool
    
    @State private var originSearchText: String = ""
    @State private var destinationSearchText: String = ""
    @State private var originSearchResults: [MPLocation] = []
    @State private var destinationSearchResults: [MPLocation] = []
    @State private var selectedOrigin: MPLocation?
    @State private var selectedDestination: MPLocation?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Directions to \(location?.name ?? "Destination")")
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Origin")
                    .font(.headline)
                SearchBar(text: $originSearchText)
                    .onChange(of: originSearchText) { newValue in
                        originSearchResults = allLocations.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                List(originSearchResults, id: \.locationId) { loc in
                    Button(action: {
                        originSearchText = loc.name
                        originSearchResults = []
                    }) {
                        Text(loc.name)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Destination")
                    .font(.headline)
                SearchBar(text: $destinationSearchText)
                    .onChange(of: destinationSearchText) { newValue in
                        destinationSearchResults = allLocations.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                List(destinationSearchResults, id: \.locationId) { loc in
                    Button(action: {
                        destinationSearchText = loc.name
                        destinationSearchResults = []
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
        .frame(height: 500)
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

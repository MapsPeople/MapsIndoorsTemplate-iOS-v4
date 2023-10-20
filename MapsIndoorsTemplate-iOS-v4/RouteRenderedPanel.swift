import SwiftUI
import MapsIndoors

struct RouteRenderedPanel: View {
    var route: MPRoute?
    
    let startPointImage = Image(systemName: "arrow.up.circle.fill")
    let endPointImage = Image(systemName: "arrow.down.circle.fill")

    var body: some View {
        VStack(spacing: 20) {
            Text("Route Information")
                .font(.headline)
                .padding(.bottom, 10)
            
            if let route = route {
                Text("Summary: \(route.summary ?? "N/A")")
                    .font(.subheadline)
                Text("Distance: \(route.distance.stringValue) meters")
                    .font(.subheadline)
                Text("Duration: \(route.duration.stringValue) seconds")
                    .font(.subheadline)
                
                ScrollView {
                    VStack {
                        ForEach(route.legs, id: \.start_address) { leg in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    startPointImage
                                        .foregroundColor(.green)
                                    Text(leg.start_address)
                                }
                                HStack {
                                    endPointImage
                                        .foregroundColor(.red)
                                    Text(leg.end_address)
                                }
                                Text("Leg Distance: \(leg.distance.stringValue) meters")
                                Text("Leg Duration: \(leg.duration.stringValue) seconds")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.vertical, 5)
                        }
                    }
                    .background(Color.yellow) // Debug background color
                }
                .frame(height: 200) // Explicit frame
                .background(Color.blue) // Debug background color
                
                if !route.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Warnings:")
                            .font(.subheadline)
                        ForEach(route.warnings, id: \.self) { warning in
                            Text("- \(warning)")
                        }
                    }
                    .padding(.top, 10)
                }
            } else {
                Text("No route details available.")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}


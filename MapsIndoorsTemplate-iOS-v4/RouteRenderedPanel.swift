import SwiftUI
import MapsIndoors

struct RouteRenderedPanel: View {
    var route: MPRoute?
    
    let startPointImage = Image(systemName: "arrow.up.circle.fill")
    let endPointImage = Image(systemName: "arrow.down.circle.fill")

    var body: some View {
        VStack(spacing: 20) {
            if let route = route {
                HStack {
                    Text("Distance: \(route.distance.stringValue) meters")
                    Spacer()
                    Text("Duration: \(route.duration.stringValue) seconds")
                }
                .font(.subheadline)
                .padding(.bottom, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(route.legs, id: \.start_address) { leg in
                            VStack {
                                Text(leg.distance.stringValue + " meters")
                                HStack {
                                    startPointImage
                                        .foregroundColor(.green)
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 150, height: 2)
                                    endPointImage
                                        .foregroundColor(.red)
                                }
                                Text(leg.duration.stringValue + " seconds")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
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

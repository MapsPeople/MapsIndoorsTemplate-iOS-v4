import SwiftUI
import MapsIndoors

struct RouteRenderedPanel: View {
    var route: MPRoute?

    var body: some View {
        VStack {
            if let route = route {
                Text("Summary: \(route.summary ?? "N/A")")
                Text("Distance: \(route.distance.stringValue) meters")
                Text("Duration: \(route.duration.stringValue) seconds")
                
                ForEach(route.legs, id: \.start_address) { leg in
                    VStack(alignment: .leading) {
                        Text("Start Address: \(leg.start_address)")
                        Text("End Address: \(leg.end_address)")
                        Text("Leg Distance: \(leg.distance.stringValue) meters")
                        Text("Leg Duration: \(leg.duration.stringValue) seconds")
                    }
                    .padding(.top)
                }
                
                if !route.warnings.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Warnings:")
                        ForEach(route.warnings, id: \.self) { warning in
                            Text("- \(warning)")
                        }
                    }
                    .padding(.top)
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

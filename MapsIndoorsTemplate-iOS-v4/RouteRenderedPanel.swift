import SwiftUI
import MapsIndoors

struct RouteRenderedPanel: View {
    var route: MPRoute?
    
    @Binding var isPresented: Bool
    
    let startPointImage = Image(systemName: "arrow.up.circle.fill")
    let endPointImage = Image(systemName: "arrow.down.circle.fill")
    
    // To keep track of the offset and translation
    @State private var offset: CGFloat = 0.0
    @State private var dragTranslation: CGFloat = 0.0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                // This is the "grabber"
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: 40, height: 5)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
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
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragTranslation = gesture.translation.height
                    }
                    .onEnded { gesture in
                        // Logic to determine if view should collapse or expand
                        let dragDistance = gesture.translation.height
                        if dragDistance > 100 { // Arbitrary value, adjust as needed
                            offset = 200 // Adjust the value to collapse as much as you want
                        } else if dragDistance < -100 {
                            offset = 0 // Reset the offset to original position
                        }
                    }
            )
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding([.top, .trailing], 12)
            }
        }
    }
}

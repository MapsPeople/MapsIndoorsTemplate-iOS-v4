import SwiftUI
import MapsIndoors
import MapsIndoorsCore

struct SidePanel: View {
    @Binding var showingSidePanelContent: Bool
    var geometry: GeometryProxy
    @ObservedObject var viewModel: MapsIndoorsViewModel
    
    @State private var isLiveDataEnabled: Bool = false
    @State private var isClusteringEnabled: Bool = false
    @State private var selectedState: Int = 0
    @State private var selectedHandlingState: CollisionHandlingState = .allowOverLap
    
    var body: some View {
        if showingSidePanelContent {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: {
                        showingSidePanelContent.toggle()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                ScrollView {
                    Text("Buildings")
                        .font(.title)
                        .padding(.top)
                    VStack(spacing: 10) {
                        ForEach(viewModel.buildings, id: \.name) { building in
                            Button(action: {
                                viewModel.mapControl?.select(building: building, behavior: .default)
                            }) {
                                Text(building.name ?? "")
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.bottom)
                }
                .frame(maxHeight: 300)
                
                Toggle("Live Data", isOn: $isLiveDataEnabled)
                    .padding(.top)
                    .onChange(of: isLiveDataEnabled) { newValue in
                        if newValue {
                            let domains = [MPLiveDomainType.occupancy, MPLiveDomainType.temperature, MPLiveDomainType.humidity, MPLiveDomainType.co2, MPLiveDomainType.availability, MPLiveDomainType.count, MPLiveDomainType.position]
                            
                            for domain in domains {
                                viewModel.mapControl?.enableLiveData(domain: domain) { liveUpdate in
                                    print("Received live update for domain \(domain): \(liveUpdate)")
                                    if let liveData = liveUpdate.getLiveValueForKey(domain) as? Int {
                                        print("The live data is for \(liveData)")
                                    }
                                }
                            }
                        }
                    }
                
                Toggle("Clustering", isOn: $isClusteringEnabled)
                    .padding(.top)
                    .onChange(of: isClusteringEnabled) { newValue in
                        MPMapsIndoors.shared.solution?.config.enableClustering = newValue
                        viewModel.mapControl?.refresh()
                    }
                
                Picker("Collision Handling", selection: $selectedHandlingState) {
                    ForEach(CollisionHandlingState.allCases, id: \.self) { state in
                        Text(state.description).tag(state)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top)
                .onChange(of: selectedHandlingState) { newValue in
                    switch newValue {
                    case .allowOverLap:
                        MPMapsIndoors.shared.solution?.config.collisionHandling = .allowOverLap
                    case .removeIconAndLabel:
                        MPMapsIndoors.shared.solution?.config.collisionHandling = .removeIconAndLabel
                    case .removeIconFirst:
                        MPMapsIndoors.shared.solution?.config.collisionHandling = .removeIconFirst
                    case .removeLabelFirst:
                        MPMapsIndoors.shared.solution?.config.collisionHandling = .removeLabelFirst
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .frame(width: 200)
            .shadow(radius: 10)
            .offset(x: showingSidePanelContent ? 0 : -geometry.size.width)
            .animation(.default, value: showingSidePanelContent)
        }
    }
}

// Define the enum for collision handling states
enum CollisionHandlingState: Int, CaseIterable {
    case allowOverLap, removeIconAndLabel, removeIconFirst, removeLabelFirst
    
    var description: String {
        switch self {
        case .allowOverLap:
            return "Allow Overlap"
        case .removeIconAndLabel:
            return "Remove Icon & Label"
        case .removeIconFirst:
            return "Remove Icon First"
        case .removeLabelFirst:
            return "Remove Label First"
        }
    }
    
    var next: CollisionHandlingState {
        return CollisionHandlingState(rawValue: (self.rawValue + 1) % 4) ?? .allowOverLap
    }
}

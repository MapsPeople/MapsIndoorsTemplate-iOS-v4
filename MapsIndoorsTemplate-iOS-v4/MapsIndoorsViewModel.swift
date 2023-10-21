import SwiftUI
import MapsIndoors

class MapsIndoorsViewModel: ObservableObject {
    @Published var isMapsIndoorsLoaded = false
    @Published var buildings: [MPBuilding] = []
    @Published var locations: [MPLocation] = []

    // For MPMapControl Delegate methods
    @Published var locationDidChange: Bool = false
    @Published var selectedLocationChanged: MPLocation?
    
    var mapControl: MPMapControl?

    
}

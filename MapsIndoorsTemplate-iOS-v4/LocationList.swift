//  LocationList.swift
import Foundation
import SwiftUI
import MapsIndoorsCore

struct LocationList: View {
    var locations: [IdentifiableLocation]
    var didSelectLocation: ((MPLocation) -> Void)?

    var body: some View {
        List(locations) { identifiableLocation in
            Text(identifiableLocation.location.name)
                .onTapGesture {
                    didSelectLocation?(identifiableLocation.location)
                }
        }
    }
}

struct IdentifiableLocation: Identifiable {
    var location: MPLocation
    var id: String {
        return location.locationId
    }
}

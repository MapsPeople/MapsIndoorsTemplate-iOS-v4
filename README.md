# MapsIndoorsTemplate-iOS-v4
This is a template application for MapsIndoors SDK. It can be integrated into your existing project.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- Xcode version 13+
- iOS version 13+

### Installing

1. Clone the repository to your local machine.
2. Navigate to the demo app directory.
3. Open the `.xcworkspace` file in Xcode.

### Configuration

This demo app uses Google Maps and Mapbox. To run the app, you need to provide your own API keys for these services.

1. Create a new plist file in the demo app directory named `APIKeys.plist`.
2. In this plist, add your API keys. The plist should have the following structure:

<dict>
    <key>GoogleMapsAPIKey</key>
    <string>your_google_maps_api_key_here</string>
    <key>MapboxAPIKey</key>
    <string>your_mapbox_api_key_here</string>
</dict>


//
//  ContentView.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import MapHero
import UIKit
import CoreLocation
struct MapHeroMapViewWrapper: UIViewRepresentable {
    let styleURL: URL?

    init(styleURLString: String) {
        self.styleURL = URL(string: styleURLString)
    }

    // Coordinator class to handle MHMapViewDelegate methods
    class Coordinator: NSObject, MHMapViewDelegate {
        var parent: MapHeroMapViewWrapper

        init(_ parent: MapHeroMapViewWrapper) {
            self.parent = parent
            super.init()
            print("MapHeroCoordinator initialized")
        }

        func mapViewWillStartLoadingMap(_ mapView: MHMapView) {
            print("Map delegate: mapViewWillStartLoadingMap")
        }

        func mapViewDidFinishLoadingMap(_ mapView: MHMapView) {
            print("Map delegate: mapViewDidFinishLoadingMap - Map loaded successfully.")
        }

        func mapViewDidFailLoadingMap(_ mapView: MHMapView, withError error: Error) {
            print("Map delegate: mapViewDidFailLoadingMap - Error: \(error.localizedDescription)")
        }

        func mapView(_ mapView: MHMapView, didFinishLoading style: MHStyle) {
            // Accessing the intended styleURL from the parent wrapper
            let intendedURLString = parent.styleURL?.absoluteString ?? "nil (intended)"
            print("Map delegate: didFinishLoadingStyle - Intended Style URL: \(intendedURLString). Loaded style name: \(style.name ?? "Unknown")")
            // You can inspect the loaded style here, e.g., style.sources, style.layers
        }
        
        // Optional: Add more delegate methods if needed for further debugging
        func mapViewWillStartRenderingMap(_ mapView: MHMapView) {
            print("Map delegate: mapViewWillStartRenderingMap")
        }

        func mapViewDidFinishRenderingMap(_ mapView: MHMapView, fullyRendered: Bool) {
            print("Map delegate: mapViewDidFinishRenderingMap - Fully Rendered: \(fullyRendered)")
        }
        
        func mapViewDidBecomeIdle(_ mapView: MHMapView) {
            print("Map delegate: mapViewDidBecomeIdle")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MHMapView {
        let mapView = MHMapView(frame: .zero, styleURL: styleURL)
        mapView.delegate = context.coordinator // Assign the coordinator as the delegate
        
        // Set zoom level to 15 and center at coordinates 31.9, 35.4
        let centerCoordinate = CLLocationCoordinate2D(latitude: 31.9, longitude: 35.4)
        mapView.setCenter(centerCoordinate, zoomLevel: 15, animated: false)
        print("MHMapView created with styleURL: \(styleURL?.absoluteString ?? "nil"), centered at (31.9, 35.4) with zoom level 15")
        
        return mapView
    }

    func updateUIView(_ uiView: MHMapView, context: Context) {
        print("MapHeroMapViewWrapper updateUIView called.")
    }
}

struct ContentView: View {
    // Using a public MapLibre demo style for testing as requested
    private let mapStyleURLString = "https://testpal61d66f.maphero.io/style.json"
    // The original style was: "https://testpal61d66f.maphero.io/style.json"

    var body: some View {
        MapHeroMapViewWrapper(styleURLString: mapStyleURLString)
            .edgesIgnoringSafeArea(.all) // Make the map full screen
    }
}

#Preview {
    ContentView()
 }

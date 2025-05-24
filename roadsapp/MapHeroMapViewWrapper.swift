//
//  MapHeroMapViewWrapper.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import MapHero
import UIKit
import CoreLocation
import Combine
import Foundation

struct MapHeroMapViewWrapper: UIViewRepresentable {
    let styleURL: URL?
    var selectedPlace: Place?
    var locationManager: LocationManager
    @ObservedObject var routeService: RouteService
    
    init(styleURLString: String, selectedPlace: Place? = nil, locationManager: LocationManager, routeService: RouteService) {
        self.styleURL = URL(string: styleURLString)
        self.selectedPlace = selectedPlace
        self.locationManager = locationManager
        self.routeService = routeService
    }

    class Coordinator: NSObject, MHMapViewDelegate {
        var parent: MapHeroMapViewWrapper
        var mapView: MHMapView?
        var marker: MHPointAnnotation?
        var userLocationMarker: MHPointAnnotation?
        var cancellables = Set<AnyCancellable>()

        init(_ parent: MapHeroMapViewWrapper) {
            self.parent = parent
            super.init()
            print("MapHeroCoordinator initialized")
            
            NotificationCenter.default.publisher(for: Notification.Name("DisplayRouteToPlace"))
                .sink { [weak self] notification in
                    guard let self = self,
                          let mapView = self.mapView,
                          let userLocation = self.parent.locationManager.location,
                          let place = notification.object as? Place else {
                        return
                    }
                    
                    self.parent.routeService.fetchAndDisplayRoute(
                        from: userLocation,
                        to: place,
                        on: mapView
                    ) { success in
                        if success {
                            print("Route displayed successfully")
                        } else {
                            print("Failed to display route")
                        }
                    }
                }
                .store(in: &cancellables)
            
            NotificationCenter.default.publisher(for: Notification.Name("RouteStopsUpdated"))
                .sink { [weak self] _ in
                    guard let self = self,
                          let mapView = self.mapView,
                          let userLocation = self.parent.locationManager.location,
                          let place = self.parent.selectedPlace else {
                        return
                    }
                    
                    self.parent.routeService.fetchAndDisplayRoute(
                        from: userLocation,
                        to: place,
                        on: mapView
                    ) { success in
                        if success {
                            print("Route with stops displayed successfully")
                        } else {
                            print("Failed to display route with stops")
                        }
                    }
                }
                .store(in: &cancellables)
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
            let intendedURLString = parent.styleURL?.absoluteString ?? "nil (intended)"
            print("Map delegate: didFinishLoadingStyle - Intended Style URL: \(intendedURLString). Loaded style name: \(style.name ?? "Unknown")")
        }
        
        func mapViewWillStartRenderingMap(_ mapView: MHMapView) {
            print("Map delegate: mapViewWillStartRenderingMap")
        }

        func mapViewDidFinishRenderingMap(_ mapView: MHMapView, fullyRendered: Bool) {
            print("Map delegate: mapViewDidFinishRenderingMap - Fully Rendered: \(fullyRendered)")
        }
        
        func mapViewDidBecomeIdle(_ mapView: MHMapView) {
            print("Map delegate: mapViewDidBecomeIdle")
        }
        
        func mapView(_ mapView: MHMapView, strokeColorForPolyline polyline: MHPolyline) -> UIColor {
            return UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) // Light blue color as shown in the image
        }
        
        func mapView(_ mapView: MHMapView, lineWidthForPolyline polyline: MHPolyline) -> CGFloat {
            return 6.0 // Slightly thicker line width as shown in the image
        }
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MHMapView {
        let mapView = MHMapView(frame: .zero, styleURL: styleURL)
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        
        if let userLocation = locationManager.location?.coordinate {
            mapView.setCenter(userLocation, zoomLevel: 13, animated: false)
            print("MHMapView created with styleURL: \(styleURL?.absoluteString ?? "nil"), centered at user's location (\(userLocation.latitude), \(userLocation.longitude)) with zoom level 13")
            
            let userMarker = MHPointAnnotation()
            userMarker.coordinate = userLocation
            userMarker.title = "My Location"
            mapView.addAnnotation(userMarker)
            context.coordinator.userLocationMarker = userMarker
        } else {
            let centerCoordinate = CLLocationCoordinate2D(latitude: 31.9, longitude: 35.4)
            mapView.setCenter(centerCoordinate, zoomLevel: 11, animated: false)
            print("MHMapView created with styleURL: \(styleURL?.absoluteString ?? "nil"), centered at default location (31.9, 35.4) with zoom level 11")
        }
        
        return mapView
    }

    func updateUIView(_ uiView: MHMapView, context: Context) {
        print("MapHeroMapViewWrapper updateUIView called.")
        
        if let userLocation = locationManager.location?.coordinate {
            if let userMarker = context.coordinator.userLocationMarker {
                userMarker.coordinate = userLocation
            } else {
                let userMarker = MHPointAnnotation()
                userMarker.coordinate = userLocation
                userMarker.title = "My Location"
                uiView.addAnnotation(userMarker)
                context.coordinator.userLocationMarker = userMarker
            }
        }
        
        if let marker = context.coordinator.marker {
            uiView.removeAnnotation(marker)
            context.coordinator.marker = nil
        }
        
        if let place = selectedPlace {
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let marker = MHPointAnnotation()
            marker.coordinate = coordinate
            marker.title = place.name
            marker.subtitle = place.address ?? ""
            
            uiView.addAnnotation(marker)
            uiView.setCenter(coordinate, zoomLevel: 14, animated: true)
            
            context.coordinator.marker = marker
        }
    }
}

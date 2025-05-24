//  Created by Omar abu sharifa on 24/05/2025.

import Foundation
import CoreLocation
import Combine
import MapHero
import SwiftUI

class RouteService: ObservableObject {
    private let mapToken = APIKeys.mapToken
    private let routeBaseURL = APIKeys.URLs.routeBaseURL
    
    private var distanceCache: [String: Double] = [:]
    
    var routeCoordinates: [CLLocationCoordinate2D]?
    var routePolyline: MHPolyline?
    
    @Published var stops: [Place] = []
    
    func calculateDistance(from userLocation: CLLocation?, to place: Place) -> Double? {
            let cacheKey = "\(place.id)"
        if let cachedDistance = distanceCache[cacheKey] {
            return cachedDistance
        }
        
        guard let userLocation = userLocation else {
            return calculateDirectDistance(from: userLocation, to: place)
        }
        
        fetchRouteDistance(from: userLocation, to: place) { [weak self] result in
            if case .success(let distance) = result {
                let distanceInKm = distance / 1000.0
                self?.distanceCache[cacheKey] = distanceInKm
                
                NotificationCenter.default.post(name: Notification.Name("RouteDistanceUpdated"), object: nil)
            }
        }
        
        let directDistance = calculateDirectDistance(from: userLocation, to: place)
        return directDistance
    }
    
    private func calculateDirectDistance(from userLocation: CLLocation?, to place: Place) -> Double? {
        guard let userLocation = userLocation else { return nil }
        
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distanceInMeters = userLocation.distance(from: placeLocation)
        
        return distanceInMeters / 1000.0
    }
    
    func fetchRouteDistance(from userLocation: CLLocation, to place: Place, completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = "\(routeBaseURL)?lat1=\(userLocation.coordinate.latitude)&lng1=\(userLocation.coordinate.longitude)&lat2=\(place.latitude)&lng2=\(place.longitude)&routeType=Fastest"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mapToken, forHTTPHeaderField: "map-token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["data"] as? [String: Any],
                   let distance = responseData["distance"] as? Double {
                    completion(.success(distance))
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addStop(_ place: Place) {
        stops.append(place)
        NotificationCenter.default.post(name: Notification.Name("RouteStopsUpdated"), object: nil)
    }
    
    func removeStop(at index: Int) {
        guard index < stops.count else { return }
        stops.remove(at: index)
        NotificationCenter.default.post(name: Notification.Name("RouteStopsUpdated"), object: nil)
    }
    
    func clearStops() {
        stops.removeAll()
        NotificationCenter.default.post(name: Notification.Name("RouteStopsUpdated"), object: nil)
    }
    
    func moveStop(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < stops.count, destinationIndex < stops.count else { return }
        let stop = stops.remove(at: sourceIndex)
        stops.insert(stop, at: destinationIndex)
        NotificationCenter.default.post(name: Notification.Name("RouteStopsUpdated"), object: nil)
    }
    
    func fetchAndDisplayRoute(from userLocation: CLLocation, to place: Place, on mapView: MHMapView, completion: @escaping (Bool) -> Void) {
        if stops.isEmpty {
            fetchDirectRoute(from: userLocation, to: place, on: mapView, completion: completion)
        } else {
            fetchRouteWithStops(from: userLocation, to: place, on: mapView, completion: completion)
        }
    }
    
    private func fetchDirectRoute(from userLocation: CLLocation, to place: Place, on mapView: MHMapView, completion: @escaping (Bool) -> Void) {
        let urlString = "\(routeBaseURL)?lat1=\(userLocation.coordinate.latitude)&lng1=\(userLocation.coordinate.longitude)&lat2=\(place.latitude)&lng2=\(place.longitude)&routeType=Fastest"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for route")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mapToken, forHTTPHeaderField: "map-token")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching route: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("No data received for route")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["data"] as? [String: Any],
                   let subSteps = responseData["subSteps"] as? [[String: Any]] {
                    
                    var routeCoords = [CLLocationCoordinate2D]()
                    
                    print("Route API response: \(json)")
                    
                    for (index, step) in subSteps.enumerated() {
                        print("Processing step \(index)")
                        
                        if let start = step["start"] as? [String: Any],
                           let startLat = start["lat"] as? Double,
                           let startLng = start["lng"] as? Double {
                            let coord = CLLocationCoordinate2D(latitude: startLat, longitude: startLng)
                            routeCoords.append(coord)
                            print("Added start coordinate: \(startLat), \(startLng)")
                        } else {
                            print("Failed to extract start coordinate from step \(index)")
                        }
                        
                        if let end = step["end"] as? [String: Any],
                           let endLat = end["lat"] as? Double,
                           let endLng = end["lng"] as? Double {
                            let coord = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
                            routeCoords.append(coord)
                            print("Added end coordinate: \(endLat), \(endLng)")
                        } else {
                            print("Failed to extract end coordinate from step \(index)")
                        }
                    }
                    
                    print("Extracted \(routeCoords.count) coordinates from route data")
                    
                    self.routeCoordinates = routeCoords
                    
                    DispatchQueue.main.async {
                        if let existingRoute = self.routePolyline {
                            mapView.remove(existingRoute)
                        }
                        
                        if !routeCoords.isEmpty {
                            let polyline = MHPolyline(coordinates: routeCoords, count: UInt(routeCoords.count))
                            mapView.add(polyline)
                            self.routePolyline = polyline
                            
                            self.addRouteMarkers(mapView: mapView, startCoord: routeCoords.first!, endCoord: routeCoords.last!)
                            
                            self.fitMapToShowRoute(mapView: mapView, coordinates: routeCoords)
                            
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    print("Invalid route data format")
                    completion(false)
                }
            } catch {
                print("Error parsing route data: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    private func addRouteMarkers(mapView: MHMapView, startCoord: CLLocationCoordinate2D, endCoord: CLLocationCoordinate2D) {
        if let annotations = mapView.annotations {
            for annotation in annotations {
                if let pointAnnotation = annotation as? MHPointAnnotation,
                   pointAnnotation.title == "Route Start" || pointAnnotation.title == "Route End" {
                    mapView.removeAnnotation(pointAnnotation)
                }
            }
        }
        
        let startMarker = MHPointAnnotation()
        startMarker.coordinate = startCoord
        startMarker.title = "Route Start"
        mapView.addAnnotation(startMarker)
        
        let endMarker = MHPointAnnotation()
        endMarker.coordinate = endCoord
        endMarker.title = "Route End"
        mapView.addAnnotation(endMarker)
    }
    
    private func fetchRouteWithStops(from userLocation: CLLocation, to place: Place, on mapView: MHMapView, completion: @escaping (Bool) -> Void) {
        
        var allPoints: [(CLLocation, String)] = []
        
        allPoints.append((userLocation, "Your Location"))
        
        for stop in stops {
            let stopLocation = CLLocation(latitude: stop.latitude, longitude: stop.longitude)
            allPoints.append((stopLocation, stop.name))
        }
        
        let destinationLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        allPoints.append((destinationLocation, place.name))
        
        var allRouteCoordinates: [CLLocationCoordinate2D] = []
        
        var allMarkers: [(CLLocationCoordinate2D, String)] = []
        
        let segmentQueue = DispatchQueue(label: "com.roadsapp.segmentQueue")
        actor SegmentCounter {
            var count = 0
            
            func increment() {
                count += 1
            }
            
            func getCount() -> Int {
                return count
            }
        }
        let completedSegments = SegmentCounter()
        let totalSegments = allPoints.count - 1
        var segmentCoordinates = [Int: [CLLocationCoordinate2D]]() // Store coordinates by segment index
        
        for i in 0..<allPoints.count {
            let point = allPoints[i]
            allMarkers.append((point.0.coordinate, point.1))
        }
        
        func fetchSegment(from fromIndex: Int, to toIndex: Int) {
            let fromPoint = allPoints[fromIndex].0
            let toPoint = allPoints[toIndex].0
            
            let urlString = "\(routeBaseURL)?lat1=\(fromPoint.coordinate.latitude)&lng1=\(fromPoint.coordinate.longitude)&lat2=\(toPoint.coordinate.latitude)&lng2=\(toPoint.coordinate.longitude)&routeType=Fastest"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL for route segment")
                segmentQueue.async {
                    Task {
                        await completedSegments.increment()
                        await checkCompletion()
                    }
                }
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(mapToken, forHTTPHeaderField: "map-token")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching route segment: \(error.localizedDescription)")
                    segmentQueue.async {
                        Task {
                            await completedSegments.increment()
                            await checkCompletion()
                        }
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received for route segment")
                    segmentQueue.async {
                        Task {
                            await completedSegments.increment()
                            await checkCompletion()
                        }
                    }
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responseData = json["data"] as? [String: Any],
                       let subSteps = responseData["subSteps"] as? [[String: Any]] {
                        
                        var segmentCoords = [CLLocationCoordinate2D]()
                        
                        for step in subSteps {
                            if let start = step["start"] as? [String: Any],
                               let startLat = start["lat"] as? Double,
                               let startLng = start["lng"] as? Double {
                                let coord = CLLocationCoordinate2D(latitude: startLat, longitude: startLng)
                                segmentCoords.append(coord)
                            }
                            
                            if let end = step["end"] as? [String: Any],
                               let endLat = end["lat"] as? Double,
                               let endLng = end["lng"] as? Double {
                                let coord = CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
                                segmentCoords.append(coord)
                            }
                        }
                        
                        segmentQueue.async {
                            segmentCoordinates[fromIndex] = segmentCoords
                            Task {
                                await completedSegments.increment()
                                await checkCompletion()
                            }
                        }
                    } else {
                        segmentQueue.async {
                            Task {
                                await completedSegments.increment()
                                await checkCompletion()
                            }
                        }
                    }
                } catch {
                    print("Error parsing route segment data: \(error.localizedDescription)")
                    segmentQueue.async {
                        Task {
                            await completedSegments.increment()
                            await checkCompletion()
                        }
                    }
                }
            }.resume()
        }
        @Sendable

        func checkCompletion() async {
            let count = await completedSegments.getCount()
            if count == totalSegments {
                DispatchQueue.main.async { [weak self] in 
                    guard let self = self else { return }
                    
                    if let existingRoute = self.routePolyline {
                        mapView.remove(existingRoute)
                    }
                    
                    if let annotations = mapView.annotations {
                        for annotation in annotations {
                            if let pointAnnotation = annotation as? MHPointAnnotation {
                                mapView.removeAnnotation(pointAnnotation)
                            }
                        }
                    }
                    
                    allRouteCoordinates = []
                    
                    for i in 0..<totalSegments {
                        if let segmentCoords = segmentCoordinates[i], !segmentCoords.isEmpty {
                            if i == 0 {
                                allRouteCoordinates.append(contentsOf: segmentCoords)
                            } else {
                                let lastPoint = allRouteCoordinates.last!
                                let firstPoint = segmentCoords.first!
                                
                                let threshold = 0.0000001 // Very small threshold for coordinate comparison
                                if abs(lastPoint.latitude - firstPoint.latitude) > threshold ||
                                   abs(lastPoint.longitude - firstPoint.longitude) > threshold {
                                    let midLat = (lastPoint.latitude + firstPoint.latitude) / 2
                                    let midLng = (lastPoint.longitude + firstPoint.longitude) / 2
                                    let connectingPoint = CLLocationCoordinate2D(latitude: midLat, longitude: midLng)
                                    allRouteCoordinates.append(connectingPoint)
                                }
                                
                                allRouteCoordinates.append(contentsOf: segmentCoords)
                            }
                        }
                    }
                    
                    if allRouteCoordinates.count >= 2 {
                        var continuousRoute = [allRouteCoordinates.first!]
                        
                        for i in 1..<allRouteCoordinates.count {
                            let prevPoint = continuousRoute.last!
                            let currentPoint = allRouteCoordinates[i]
                            
                            let distance = sqrt(pow(prevPoint.latitude - currentPoint.latitude, 2) + 
                                              pow(prevPoint.longitude - currentPoint.longitude, 2))
                            
                            if distance > 0.001 {
                                let steps = max(2, Int(distance * 1000)) // More points for larger gaps
                                for step in 1..<steps {
                                    let fraction = Double(step) / Double(steps)
                                    let intermediateLat = prevPoint.latitude + fraction * (currentPoint.latitude - prevPoint.latitude)
                                    let intermediateLng = prevPoint.longitude + fraction * (currentPoint.longitude - prevPoint.longitude)
                                    continuousRoute.append(CLLocationCoordinate2D(latitude: intermediateLat, longitude: intermediateLng))
                                }
                            }
                            
                            continuousRoute.append(currentPoint)
                        }
                        
                        allRouteCoordinates = continuousRoute
                    }
                    
                    if !allRouteCoordinates.isEmpty {
                        self.routeCoordinates = allRouteCoordinates
                        
                        let polyline = MHPolyline(coordinates: allRouteCoordinates, count: UInt(allRouteCoordinates.count))
                        mapView.add(polyline)
                        self.routePolyline = polyline
                        
                        for (index, marker) in allMarkers.enumerated() {
                            let pointAnnotation = MHPointAnnotation()
                            pointAnnotation.coordinate = marker.0
                            pointAnnotation.title = marker.1
                            
                            if index == 0 {
                                pointAnnotation.subtitle = "Start"
                            } else if index == allMarkers.count - 1 {
                                pointAnnotation.subtitle = "Destination"
                            } else {
                                pointAnnotation.subtitle = "Stop \(index)"
                            }
                            
                            mapView.addAnnotation(pointAnnotation)
                        }
                        
                        self.fitMapToShowRoute(mapView: mapView, coordinates: allRouteCoordinates)
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
        
        for i in 0..<(allPoints.count - 1) {
            fetchSegment(from: i, to: i + 1)
        }
    }
    
    private func fitMapToShowRoute(mapView: MHMapView, coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else { return }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLng = coordinates[0].longitude
        var maxLng = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLng = min(minLng, coordinate.longitude)
            maxLng = max(maxLng, coordinate.longitude)
        }
        
        let padding: Double = 0.01 // About 1km of padding
        let paddedSouthwest = CLLocationCoordinate2D(latitude: minLat - padding, longitude: minLng - padding)
        let paddedNortheast = CLLocationCoordinate2D(latitude: maxLat + padding, longitude: maxLng + padding)
        
        let bounds = MHCoordinateBounds(sw: paddedSouthwest, ne: paddedNortheast)
        mapView.setVisibleCoordinateBounds(bounds, animated: true)
    }
}

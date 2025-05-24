//
//  PlaceSearchService.swift
//  roadsapp
//
//  Created on 24/05/2025.
//

import Foundation
import Combine
import SwiftUI

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Place: Codable, Identifiable {
    let id: String
    let name: String
    let nameEn: String?
    let nameAr: String?
    let type: String?
    let governorate: String?
    let governorateAr: String?
    let locality: String?
    let localityEn: String?
    let localityAr: String?
    let location: Location?
    let latitude: Double
    let longitude: Double
    let weight: Int?
    let distance: Double?
    let listed: Bool?
    
    var address: String? {
        if let locality = locality, let governorate = governorate {
            return "\(locality), \(governorate)"
        } else if let locality = locality {
            return locality
        } else if let governorate = governorate {
            return governorate
        }
        return nil
    }
    
    var category: String? {
        return type
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case nameEn
        case nameAr
        case type
        case governorate
        case governorateAr
        case locality
        case localityEn
        case localityAr
        case location
        case latitude
        case longitude
        case weight
        case distance
        case listed
    }
}

struct ApiResponse: Codable {
    let status: Int
    let message: String
    let data: [Place]
}

class PlaceSearchService {
    private let baseURL = APIKeys.URLs.placeSearchBaseURL
    private let mapToken = APIKeys.mapToken
    private let locationManager: LocationManager
    
    init(locationManager: LocationManager? = nil) {
        self.locationManager = locationManager ?? LocationManager()
    }
    
    func searchPlaces(query: String) -> AnyPublisher<[Place], Error> {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?key=\(encodedQuery)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mapToken, forHTTPHeaderField: "map-token")
        
        print("Sending request to: \(url.absoluteString)")
        print("With header map-token: \(mapToken)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response: \(jsonString)")
                }
            })
            .decode(type: ApiResponse.self, decoder: JSONDecoder())
            .map { [weak self] response -> [Place] in
                guard let self = self else { return response.data }
                
                let placesWithDistances = response.data.map { place -> Place in
                    var updatedPlace = place
                    
                    if let distance = self.locationManager.calculateDistance(to: place) {
                        updatedPlace = Place(
                            id: place.id,
                            name: place.name,
                            nameEn: place.nameEn,
                            nameAr: place.nameAr,
                            type: place.type,
                            governorate: place.governorate,
                            governorateAr: place.governorateAr,
                            locality: place.locality,
                            localityEn: place.localityEn,
                            localityAr: place.localityAr,
                            location: place.location,
                            latitude: place.latitude,
                            longitude: place.longitude,
                            weight: place.weight,
                            distance: distance,
                            listed: place.listed
                        )
                    }
                    return updatedPlace
                }
                
                return placesWithDistances.sorted { (place1, place2) -> Bool in
                    guard let distance1 = place1.distance else { return false }
                    guard let distance2 = place2.distance else { return true }
                    return distance1 < distance2
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

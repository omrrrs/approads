//
//  SearchViewModel.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import Combine
import CoreLocation

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var places: [Place] = []
    @Published var selectedPlace: Place?
    @Published var isSearching = false
    @Published var isShowingSearchResults = false
    
    private var cancellables = Set<AnyCancellable>()
    private var searchService: PlaceSearchService
    
    private(set) var locationManager: LocationManager?
    
    init(locationManager: LocationManager? = nil) {
        self.locationManager = locationManager
        if let locationManager = locationManager {
            self.searchService = PlaceSearchService(locationManager: locationManager)
        } else {
            self.searchService = PlaceSearchService()
        }
        
        setupLocationManagerObserver()
    }
    
    func updateLocationManager(_ manager: LocationManager) {
        self.locationManager = manager
        self.searchService = PlaceSearchService(locationManager: manager)
        setupLocationManagerObserver()
        
        if !places.isEmpty {
            performSearch()
        }
    }
    
    private func setupLocationManagerObserver() {
        cancellables.removeAll()
        
        locationManager?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                
                if let places = self?.places, !places.isEmpty {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        
        print("Starting search for: \(searchText)")
        isSearching = true
        places = []
        
        searchService.searchPlaces(query: searchText)
            .sink(
                receiveCompletion: { completion in
                    self.isSearching = false
                    if case .failure(let error) = completion {
                        print("Search error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { searchResults in
                    print("Received \(searchResults.count) search results")
                    self.places = searchResults
                    
                    self.isShowingSearchResults = true
                    print("Setting isShowingSearchResults to true")
                    
                    if self.places.isEmpty {
                        print("No results found, using mock data")
                    }
                }
            )
            .store(in: &cancellables)
    }
    

    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

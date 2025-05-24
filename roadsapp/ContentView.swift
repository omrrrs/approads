//  Created by Omar abu sharifa on 24/05/2025.

import SwiftUI
import UIKit
import MapHero
import Combine
import CoreLocation
import Foundation

struct ContentView: View {
    private let mapStyleURLString = APIKeys.URLs.mapStyleURL
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel: SearchViewModel
    @StateObject private var routeService = RouteService()
    @State private var isShowingStopsView = true
    @State private var isShowingDistanceCards = false
    
    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name("ShowDistanceCards"), object: nil, queue: .main) { notification in
            withAnimation {
                self.isShowingStopsView = false
                self.isShowingDistanceCards = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MapHeroMapViewWrapper(
                    styleURLString: mapStyleURLString, 
                    selectedPlace: viewModel.selectedPlace, 
                    locationManager: locationManager,
                    routeService: routeService
                )
                .edgesIgnoringSafeArea(.all)
                .navigationDestination(isPresented: $viewModel.isShowingSearchResults) {
                        SearchResultsView(
                            selectedPlace: $viewModel.selectedPlace,
                            searchText: viewModel.searchText,
                            places: viewModel.places,
                            locationManager: locationManager
                        )
                        .navigationBarHidden(true)
                    }
                
                SearchBarView(
                    searchText: $viewModel.searchText,
                    onSubmit: {
                        if !viewModel.searchText.isEmpty {
                            viewModel.performSearch()
                            viewModel.hideKeyboard()
                        }
                    },
                    onSearchButtonTap: {
                        if !viewModel.searchText.isEmpty {
                            viewModel.performSearch()
                            viewModel.hideKeyboard()
                        }
                    }
                )
                
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 70) // Position below search bar
                }
                
                Spacer()
                
                if let place = viewModel.selectedPlace, !viewModel.isShowingSearchResults {
                    VStack {
                        if isShowingStopsView {
                            StopsView(
                                routeService: routeService,
                                selectedPlace: $viewModel.selectedPlace
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70) // Position below search bar
                            .transition(.move(edge: .top))
                            
                            Spacer()
                            
                            PlaceDetailCard(place: place, routeService: routeService)
                        } 
                        else if isShowingDistanceCards {
                            Spacer() // Push everything to the bottom
                            
                            DistanceCardsView(
                                routeService: routeService,
                                destination: place
                            )
                            .transition(.move(edge: .bottom))
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.locationManager == nil {
                    viewModel.updateLocationManager(locationManager)
                }
                setupNotifications()
            }
        }
    }
}

#Preview {
    ContentView()
}

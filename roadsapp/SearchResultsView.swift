//
//  SearchResultsView.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import UIKit

struct SearchResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedPlace: Place?
    let searchText: String
    let places: [Place]
    let locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                        
                        Text(searchText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                
                Spacer()
                
                Button(action: {
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(places) { place in
                        Button(action: {
                            selectedPlace = place
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: IconUtility.iconForCategory(place.category))
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                                    .padding(6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(place.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Text(place.address ?? "Unknown location")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text(formatDistance(place: place))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func formatDistance(place: Place) -> String {
        if let distance = place.distance {
            return String(format: "%.1f km", distance)
        }
        
        if let calculatedDistance = locationManager.calculateDistance(to: place) {
            return String(format: "%.1f km", calculatedDistance)
        }
        
        return "-- km"
    }
}

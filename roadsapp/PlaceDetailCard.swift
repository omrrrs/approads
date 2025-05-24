//
//  PlaceDetailCard.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import CoreLocation

struct PlaceDetailCard: View {
    let place: Place
    var routeService: RouteService?
    
    var body: some View {
        VStack(spacing: 8) {
            Text(place.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 5) {
                Text(place.distance != nil ? String(format: "%.1f km", place.distance!) : "-- km")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                
                Text("•")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.horizontal, 2)
                
                Text(place.address ?? "Unknown location")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: {
                    NotificationCenter.default.post(
                        name: Notification.Name("DisplayRouteToPlace"),
                        object: place
                    )
                    
                    NotificationCenter.default.post(
                        name: Notification.Name("ShowDistanceCards"),
                        object: place
                    )
                }) {
                    HStack {
                        Image(systemName: "location.north.fill")
                            .foregroundColor(.white)
                        Text("Directions")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(red: 0.3, green: 0.7, blue: 0.9))
                    .cornerRadius(20)
                }
                
                Spacer()
                
                Button(action: {
                }) {
                    Image(systemName: "star")
                        .foregroundColor(.black)
                        .font(.system(size: 22))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

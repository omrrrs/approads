//
//  DistanceCardsView.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import CoreLocation

struct DistanceCardsView: View {
    @ObservedObject var routeService: RouteService
    let destination: Place
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Best Route")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    if let distance = destination.distance {
                        let estimatedMinutes = Int(distance * 60 / 40)
                        Text("\(estimatedMinutes) min (\(String(format: "%.1f", distance)) km)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    } else {
                        Text("30 min (5.0 km)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Best Route")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Start button
                Button(action: {
                    // Start navigation
                }) {
                    HStack {
                        Image(systemName: "location.north.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        Text("Start")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.top, 4)
                
                // Action buttons
                HStack(spacing: 30) {
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .padding(.horizontal, 16)
    }
}

//
//  StopsView.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import CoreLocation

struct StopsView: View {
    @ObservedObject var routeService: RouteService
    @Binding var selectedPlace: Place?
    @State private var isAddingStop = false
    @State private var userLocation: String = "Your Location"
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                        .frame(width: 16, height: 16)
                    
                    Text(userLocation)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                if !routeService.stops.isEmpty || selectedPlace != nil {
                    VStack(spacing: 3) {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2, height: 2)
                        }
                    }
                    .padding(.vertical, 3)
                    .padding(.leading, 26)
                }
                
                ForEach(routeService.stops.indices, id: \.self) { index in
                    let stop = routeService.stops[index]
                    
                    HStack(spacing: 10) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                        
                        Text(stop.name)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            Button(action: {
                                routeService.removeStop(at: index)
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    
                    if index < routeService.stops.count - 1 || selectedPlace != nil {
                        VStack(spacing: 3) {
                            ForEach(0..<5) { _ in
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 2)
                            }
                        }
                        .padding(.vertical, 3)
                        .padding(.leading, 26)
                    }
                }
                
                if let destination = selectedPlace {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20, height: 20)
                        
                        Text(destination.name)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 16)
            
            Button(action: {
                isAddingStop = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 16)
            
            Text("Add Stop")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $isAddingStop) {
            StopSearchView(routeService: routeService, isPresented: $isAddingStop)
        }
    }
}

struct StopSearchView: View {
    @ObservedObject var routeService: RouteService
    @Binding var isPresented: Bool
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search for a stop", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top)
                    .onSubmit {
                        viewModel.searchText = searchText
                        viewModel.performSearch()
                    }
                
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                } else if viewModel.places.isEmpty && !searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.places) { place in
                        Button(action: {
                            routeService.addStop(place)
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(place.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    if let address = place.address {
                                        Text(address)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                if let distance = place.distance {
                                    Text(String(format: "%.1f km", distance))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Add Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    StopsView(
        routeService: RouteService(),
        selectedPlace: .constant(nil)
    )
}

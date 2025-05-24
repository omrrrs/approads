//
//  SearchBarView.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSubmit: () -> Void
    var onSearchButtonTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.black)
                .padding(.leading, 8)
            
            TextField("Search places...", text: $searchText)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .foregroundColor(.black)
                .onSubmit {
                    if !searchText.isEmpty {
                        onSubmit()
                    }
                }
            
            Button(action: {
                if !searchText.isEmpty {
                    onSearchButtonTap()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                    .padding(.trailing, 8)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

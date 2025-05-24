//
//  IconUtility.swift
//  roadsapp
//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI

struct IconUtility {
    static func iconForCategory(_ category: String?) -> String {
        guard let category = category else { return "mappin" }
        
        switch category.lowercased() {
        case "pharmacy":
            return "cross.fill"
        case "food", "restaurant":
            return "fork.knife"
        case "fuel", "gas", "station":
            return "fuelpump.fill"
        case "home", "building", "residence":
            return "house.fill"
        case "university", "school":
            return "book.fill"
        case "hotel":
            return "bed.double.fill"
        case "police":
            return "shield.fill"
        case "governorate", "locality":
            return "map.fill"
        case "public_building":
            return "building.2.fill"
        case "hospital", "medical":
            return "heart.text.square.fill"
        case "park":
            return "leaf.fill"
        case "stadium":
            return "sportscourt.fill"
        case "cafe":
            return "cup.and.saucer.fill"
        case "point_of_interest":
            return "star.fill"
        default:
            return "mappin"
        }
    }
}

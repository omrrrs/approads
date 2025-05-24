//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import MapHero

@main
struct roadsappApp: App {
    private let mapHeroToken = "a8Kla1mcQY1uudLZ1v_UvP5qBZEtWxG8R_ss"

    init() {
        // Enable verbose logging for MapHero SDK FIRST
        let loggingConfig = MHLoggingConfiguration.shared // Corrected based on compiler error
        loggingConfig.loggingLevel = .verbose 
        print("MapHero SDK verbose logging enabled.")

        let token = "a8Kla1mcQY1uudLZ1v_UvP5qBZEtWxG8R_ss"
        let networkConfig = MHNetworkConfiguration.sharedManager
        
        let sessionConfig = networkConfig.sessionConfiguration ?? URLSessionConfiguration.default
        
        var headers = sessionConfig.httpAdditionalHeaders ?? [:]
        headers["map-token"] = token
        sessionConfig.httpAdditionalHeaders = headers
        
        networkConfig.sessionConfiguration = sessionConfig
        
        networkConfig.setToken(token)
        
        MHSettings.apiKey = token
        
        MHSettings.use(.mapLibre)
        
        print("MapHero token set in MHSettings.apiKey, MHNetworkConfiguration.token, and as 'map-token' header in URLSessionConfiguration")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  Created by Omar abu sharifa on 24/05/2025.
//

import SwiftUI
import MapHero

@main
struct roadsappApp: App {
    private let mapHeroToken = APIKeys.mapToken

    init() {
        let loggingConfig = MHLoggingConfiguration.shared 
        loggingConfig.loggingLevel = .verbose 
        print("MapHero SDK verbose logging enabled.")

        let token = APIKeys.mapToken
        let networkConfig = MHNetworkConfiguration.sharedManager
        
        let sessionConfig = networkConfig.sessionConfiguration ?? URLSessionConfiguration.default
        
        var headers = sessionConfig.httpAdditionalHeaders ?? [:]
        headers["map-token"] = token
        sessionConfig.httpAdditionalHeaders = headers
        
        networkConfig.sessionConfiguration = sessionConfig
        
        networkConfig.setToken(token)
        
        MHSettings.apiKey = token
        
        MHSettings.use(.mapLibre)
        
        MHNetworkConfiguration.sharedManager.setToken(mapHeroToken)
        
        print("MapHero token set in MHSettings.apiKey, MHNetworkConfiguration.token, and as 'map-token' header in URLSessionConfiguration")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

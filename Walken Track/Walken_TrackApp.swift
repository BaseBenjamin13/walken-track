//
//  Walken_TrackApp.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/3/24.
//

import SwiftUI

@main
struct Walken_TrackApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}

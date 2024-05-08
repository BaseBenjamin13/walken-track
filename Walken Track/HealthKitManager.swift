//
//  HealthKitManager.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/8/24.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
        // ADD MORE TYPES TO EXPAND APP
}

//
//  HealthMetric.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/9/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

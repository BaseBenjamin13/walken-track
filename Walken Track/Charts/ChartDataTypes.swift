//
//  ChartDataTypes.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/11/24.
//

import Foundation


struct WeekdayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

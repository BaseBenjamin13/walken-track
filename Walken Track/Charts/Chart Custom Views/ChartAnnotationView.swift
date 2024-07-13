//
//  ChartAnnotationView.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/11/24.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    let data: DateValueChartData
    let context: HealthMetricContext
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.4))
            .offset(y: -10)
            .annotation(
                position: .top,
                spacing: 0,
                overflowResolution: .init(
                    x: .fit(to: .chart),
                    y: .disabled)
            ) { annotationView }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(
                data.date,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            Text(
                data.value,
                format: .number.precision(.fractionLength(context == .steps ? 0 : 1))
            )
                .fontWeight(.heavy)
                .foregroundStyle(context == .steps ? .pink : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.4), radius: 4, x: 4, y: 4)
        )
    }
}

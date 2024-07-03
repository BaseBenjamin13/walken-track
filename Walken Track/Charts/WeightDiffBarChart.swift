//
//  WeightDiffBarChart.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/3/24.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var chartData: [WeekdayChartData]
    
    var selectedData: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Label("Average Weight Change", systemImage: "figure")
                        .font(.title3.bold())
                        .foregroundStyle(.linearGradient(
                            colors: [.black.opacity(0.7), .indigo, .indigo],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                    
                    Text("Per Weekday (Last 28 days)")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.4))
                        .offset(y: -10)
                        .annotation(
                            position: .top,
                            spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled)
                        ) {
                            annotationView
                        }
                }

                ForEach(chartData) { weightDiff in
                    BarMark(
                        x: .value("Date", weightDiff.date, unit: .day),
                        y: .value("Weight Diff", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? Color.red.gradient : Color.indigo.gradient)
                    .opacity(rawSelectedDate == nil ||
                        weightDiff.date == selectedData?.date ? 1.0 : 0.4
                    )
                    .cornerRadius(8)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(
                selectedData?.date ?? .now,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            Text(
                selectedData?.value ?? 0,
                format: .number.precision(.fractionLength(2))
            )
                .fontWeight(.heavy)
                .foregroundStyle((selectedData?.value ?? 0) >= 0 ? .red : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.4), radius: 4, x: 4, y: 4)
        )
    }
    
}

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}

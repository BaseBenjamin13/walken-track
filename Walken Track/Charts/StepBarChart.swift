//
//  StepBarChart.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/11/24.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var avgStepCount: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalSteps = chartData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(chartData.count)
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Steps", systemImage: "figure.walk")
                            .font(.title3.bold())
                            .foregroundStyle(.linearGradient(
                                colors: [.black.opacity(0.7), .pink, .pink],
                                startPoint: .bottom,
                                endPoint: .top
                            ))
                        
                        Text("Avg: \(Int(avgStepCount)) Steps")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no step data from the Health App.")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
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
                    
                    RuleMark(y: .value("Average", avgStepCount))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(.linearGradient(
                            colors: [.black.opacity(0.7), .pink, .pink, .pink],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .opacity(rawSelectedDate == nil ||
                            steps.date == selectedHealthMetric?.date ? 1.0 : 0.4
                        )
                        .cornerRadius(8)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                        .foregroundStyle(.pink)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((
                            value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                        .foregroundStyle(.pink)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(
                selectedHealthMetric?.date ?? .now,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            Text(
                selectedHealthMetric?.value ?? 0,
                format: .number.precision(.fractionLength(0))
            )
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
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
    StepBarChart(selectedStat: .steps, chartData: MockData.steps)
}

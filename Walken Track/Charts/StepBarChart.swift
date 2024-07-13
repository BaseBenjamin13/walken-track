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
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    var avgStepCount: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var body: some View {
        let config = ChartContainerConfig(
            title: "Steps",
            symbol: "figure.walk",
            subtitle: "Avg: \(avgStepCount.formatted()) Steps",
            context: .steps,
            isNav: true
        )
        
        ChartContainer(config: config) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .steps)
                }
                if !chartData.isEmpty {
                    RuleMark(y: .value("Average", avgStepCount))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                }
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
                             steps.date == selectedData?.date ? 1.0 : 0.4
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
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no step data from the Health App.")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
}

#Preview {
    StepBarChart(chartData: []) //chartData: ChartHelper.convert(data: MockData.steps)
}

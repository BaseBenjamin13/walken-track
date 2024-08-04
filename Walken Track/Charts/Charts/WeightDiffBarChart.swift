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
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        ChartContainer(chartType: .weightDiffBar) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                ForEach(chartData) { weightDiff in
                    Plot {
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
                    .accessibilityLabel(weightDiff.date.weekdayTitle)
                    .accessibilityValue("\(weightDiff.value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))) pounds")
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
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
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

//struct WeightBarMark: View {
//    var weightDiff: DateValueChartData
//    var rawSelectedDate: Date?
//    var selectedData: DateValueChartData?
//    var body: some View {
//        Plot {
//            BarMark(
//                x: .value("Date", weightDiff.date, unit: .day),
//                y: .value("Weight Diff", weightDiff.value)
//            )
//            .foregroundStyle(weightDiff.value >= 0 ? Color.red.gradient : Color.indigo.gradient)
//            .opacity(rawSelectedDate == nil ||
//                     weightDiff.date == selectedData?.date ? 1.0 : 0.4
//            )
//            .cornerRadius(8)
//        }
//        .accessibilityLabel(weightDiff.date.weekdayTitle)
//        .accessibilityValue("\(weightDiff.value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))) pounds")
//    }
//}

#Preview {
    WeightDiffBarChart(chartData: []) //chartData: MockData.weightDiffs
}

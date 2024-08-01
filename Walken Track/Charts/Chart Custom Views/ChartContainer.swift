//
//  ChartContainer.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/10/24.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainer<Content: View>: View {
    let chartType: ChartType

    @ViewBuilder var content : () -> Content
    

    
    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view")
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(.linearGradient(
                    colors: context == .steps ? [.black.opacity(0.7), .pink, .pink] : [.black.opacity(0.7), .indigo, .indigo],
                    startPoint: .bottom,
                    endPoint: .top
                ))
            Text(subtitle)
                .font(.caption)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityElement(children: .ignore)
    }
    
    var isNav: Bool {
        switch chartType {
        case .stepBar(_), .weightLine(_):
            return true
        case .stepWeekdayPie, .weightDiffBar:
            return false
        }
    }
    var context: HealthMetricContext {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
            .steps
        case .weightLine(_), .weightDiffBar:
            .weight
        }
    }
    var title: String {
        switch chartType {
        case .stepBar(_):
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine(_):
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        }
    }    
    var symbol: String {
        switch chartType {
        case .stepBar(_):
            "figure.walk"
        case .stepWeekdayPie:
            "calender"
        case .weightLine(_), .weightDiffBar:
            "figure"
        }
    }
    var subtitle: String {
        switch chartType {
        case .stepBar(let average):
            "Avg: \(average.formatted()) Steps"
        case .stepWeekdayPie:
            "Last 28 Days"
        case .weightLine(let average):
            "Avg \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 days)"
        }
    }
    var accessibilityLabel: String {
        switch chartType {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average) steps"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(let average):
            "Line chart, weight, average weight:  \(average.formatted(.number.precision(.fractionLength(1)))) pounds"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        }
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}

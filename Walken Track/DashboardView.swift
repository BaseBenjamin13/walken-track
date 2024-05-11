//
//  DashboardView.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/3/24.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPersissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var rawSelectedDate: Date?
    var isSteps: Bool { selectedStat == .steps }
    
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else { return 0 }
        let totalSteps = hkManager.stepData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(hkManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return hkManager.stepData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Steps", systemImage: "figure.walk")
                                        .font(.title3.bold())
//                                        .foregroundStyle(.pink)
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
                            
//                            ForEach(HealthMetric.mockData) { steps in
                            ForEach(hkManager.stepData) { steps in
                                BarMark(
                                    x: .value("Date", steps.date, unit: .day),
                                    y: .value("Steps", steps.value)
                                )
//                                .foregroundStyle(Color.pink.gradient)
                                .foregroundStyle(.linearGradient(
                                    colors: [.black.opacity(0.7), .pink, .pink, .pink],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ))
                                .opacity(rawSelectedDate == nil || 
                                    steps.date == selectedHealthMetric?.date ? 1.0 : 0.4
                                )
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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
//                                .foregroundStyle(.pink)
                                .foregroundStyle(.linearGradient(
                                    colors: [.black.opacity(0.7), .pink, .pink],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ))
                            
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task {
                //                await hkManager.addSimulatorData()
                await hkManager.fetchStepCount()
                //                await hkManager.fetchWeights()
                isShowingPermissionPrimingSheet = !hasSeenPersissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) {
                HealthDataListView(metric: $0, isSteps: isSteps)
            }
            .sheet(
                isPresented: $isShowingPermissionPrimingSheet,
                onDismiss: {
                    
                },
                content: {
                    HealthKitPermissionPrimingView(hasSeen: $hasSeenPersissionPriming)
                }
            )
        }
        .tint(isSteps ? .pink : .indigo)
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
    DashboardView()
        .environment(HealthKitManager())
}

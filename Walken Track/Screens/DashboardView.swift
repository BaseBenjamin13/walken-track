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
    var isSteps: Bool { selectedStat == .steps }

    
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
                    
                    StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)

                    StepPieChart(
                        chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData)
                    )
                }
            }
            .padding()
            .task {
//                await hkManager.addSimulatorData()
                isShowingPermissionPrimingSheet = !hasSeenPersissionPriming
                await hkManager.fetchStepCount()
                ChartMath.averageWeekdayCount(for: hkManager.stepData)
                //                await hkManager.fetchWeights()
                
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
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}

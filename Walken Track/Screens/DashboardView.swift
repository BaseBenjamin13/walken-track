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
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)
                        StepPieChart(
                            chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData)
                        )
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: hkManager.weightData)
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task {
//                await hkManager.addSimulatorData()
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightForDifferentials()
                } catch STError.authNotDetermined {
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    print("❌No Data Error")
                } catch {
                    print("❌ unable to complete request")
                }
//                ChartMath.averageWeekdayCount(for: hkManager.stepData)
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) {
                HealthDataListView(metric: $0, isSteps: isSteps, isShowingPermissionPriming: $isShowingPermissionPrimingSheet)
            }
            .sheet(
                isPresented: $isShowingPermissionPrimingSheet,
                onDismiss: {
                    
                },
                content: {
                    HealthKitPermissionPrimingView()
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

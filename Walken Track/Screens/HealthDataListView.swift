//
//  HealthDataListView.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 5/6/24.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingAddData = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricContext
    var isSteps: Bool
    @Binding var isShowingPermissionPriming: Bool
    
    var listData: [HealthMetric] {
        isSteps ? hkManager.stepData : hkManager.weightData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(
                    data.value,
                    format: .number.precision(.fractionLength(isSteps ? 0 : 1))
                )
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(isSteps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            if isSteps {
                                do {
                                    try await hkManager.addStepData(
                                        for: addDataDate,
                                        value: Double(valueToAdd)!
                                    )
                                    try await hkManager.fetchStepCount()
                                    isShowingAddData = false
                                } catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                } catch STError.sharingDenied(let quantityType) {
                                    print("❌ sharing denied for \(quantityType)")
                                } catch {
                                    print("❌ data list view unable to complete request")
                                }
                                
                            } else {
                                do {
                                    try await hkManager.addWeightData(
                                        for: addDataDate,
                                        value: Double(valueToAdd)!
                                    )
                                    try await hkManager.fetchWeights()
                                    try await hkManager.fetchWeightForDifferentials()
                                    isShowingAddData = false
                                } catch STError.authNotDetermined {
                                    isShowingPermissionPriming = true
                                } catch STError.sharingDenied(let quantityType) {
                                    print("❌ sharing denied for \(quantityType)")
                                } catch {
                                    print("❌ data list view unable to complete request")
                                }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps, isSteps: true, isShowingPermissionPriming: .constant(false))
            .environment(HealthKitManager())
    }
}

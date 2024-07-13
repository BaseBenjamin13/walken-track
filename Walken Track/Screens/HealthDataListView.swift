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
    @State private var isShowingAlert = false
    @State private var writeError: STError = .noData
    
    var metric: HealthMetricContext
    var isSteps: Bool
    @Binding var isShowingPermissionPriming: Bool
    
    var listData: [HealthMetric] {
        isSteps ? hkManager.stepData : hkManager.weightData
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                LabeledContent {
                    Text(
                        data.value,
                        format: .number.precision(.fractionLength(isSteps ? 0 : 1))
                    )
                } label: {
                    Text(data.date, format: .dateTime.month().day().year())
                }
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
                LabeledContent(metric.title) {
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(isSteps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest:
                    Button("Contact") {
                        // try to open email app, unsure if this works, no email app on simulator
                        UIApplication.shared.canOpenURL(URL(string: "message://benmorgiewicz@gmail.com")!)
                    }
                    Button("Cancel", role: .cancel) {}
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) {}
                case .invalidValue:
                    Button("OK", role: .cancel) {}
                }
            } message: { writeError in
                Text(writeError.failureReason ?? "Failed to add Data.")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        addDataToHealthKit()
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
    private func addDataToHealthKit() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valueToAdd = ""
            return
        }
        Task {
            do {
                if isSteps {
                    try await hkManager.addStepData(
                        for: addDataDate,
                        value: value
                    )
                    hkManager.stepData = try await hkManager.fetchStepCount()
                } else {
                    try await hkManager.addWeightData(
                        for: addDataDate,
                        value: value
                    )
                    async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                    hkManager.weightData = try await weightsForLineChart
                    hkManager.weightDiffData = try await weightsForDiffBarChart
                }
                isShowingAddData = false
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
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

//
//  ChartContainer.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/10/24.
//

import SwiftUI

struct ChartContainerConfig {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
}

struct ChartContainer<Content: View>: View {
    let config: ChartContainerConfig

    @ViewBuilder var content : () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
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
        NavigationLink(value: config.context) {
            HStack {
                titleView
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(.linearGradient(
                    colors: config.context == .steps ? [.black.opacity(0.7), .pink, .pink] : [.black.opacity(0.7), .indigo, .indigo],
                    startPoint: .bottom,
                    endPoint: .top
                ))
            Text(config.subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(config: .init(title: "Test", symbol: "figure.walk", subtitle: "Text subtitle", context: .steps, isNav: false)) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}

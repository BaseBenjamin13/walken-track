//
//  ChartContainer.swift
//  Walken Track
//
//  Created by Ben Morgiewicz on 7/10/24.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
    
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
    }
}

#Preview {
    ChartContainer(title: "Test", symbol: "figure.walk", subtitle: "Text subtitle", context: .steps, isNav: false) {
        Text("Chart goes here")
            .frame(height: 150)
    }
}

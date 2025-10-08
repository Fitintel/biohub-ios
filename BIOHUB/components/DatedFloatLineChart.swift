//
//  DatedFloatLineChart.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-07.
//

import SwiftUI
import simd
import Charts
import OSLog

struct DatedFloatLineChart: View {
    
    let max: Float
    @Bindable var data: DatedFloatSegments
    @State private var lastSnapshot: [[DatedFloat]] = []
    @State private var snapshotTask: Task<Void, Never>? = nil
    
    var body: some View {
        Chart {
            let segments: [[DatedFloat]] = lastSnapshot
            ForEach(segments.indices, id:\.self) { i in
                ForEach(segments[i]) { (point: DatedFloat) in
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Value", point.read),
                             series: .value("Series", "V\(i)"))
                    .foregroundStyle(by: .value("Axis", "Value"))
                }
            }
        }
        .chartYScale(domain: (-max)...(max))
        .chartForegroundStyleScale([
            "Value": .red,
        ])
        .frame(height: 250)
        .onAppear {
            snapshotTask?.cancel()
            snapshotTask = Task {
                let interval: Duration = .milliseconds(90)
                while !Task.isCancelled {
                    await MainActor.run {
                        lastSnapshot = data.segments.map { Array($0.list) }
                    }
                    try? await Task.sleep(for: interval)
                }
            }
        }
        .onDisappear {
            snapshotTask?.cancel()
            snapshotTask = nil
        }
    }
}

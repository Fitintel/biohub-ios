//
//  DatedSIMD3ListView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import SwiftUI
import simd
import Charts
import OSLog

struct DatedSIMD3LineChart: View {
    
    let max: Float
    @Bindable var data: DatedSIMD3FSegments
    @State private var lastSnapshot: [[DatedSIMD3F]] = []
    @State private var snapshotTask: Task<Void, Never>? = nil
    
    var body: some View {
        Chart {
            let segments: [[DatedSIMD3F]] = lastSnapshot
            ForEach(segments.indices, id:\.self) { i in
                ForEach(segments[i]) { point in
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("X", point.read.x),
                             series: .value("Series", "X\(i)"))
                    .foregroundStyle(by: .value("Axis", "X"))
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Y", point.read.y),
                             series: .value("Series", "Y\(i)"))
                    .foregroundStyle(by: .value("Axis", "Y"))
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Z", point.read.z),
                             series: .value("Series", "Z\(i)"))
                    .foregroundStyle(by: .value("Axis", "Z"))
                }
            }
        }
        .chartYScale(domain: (-max)...(max))
        .chartForegroundStyleScale([
            "X": .red,
            "Y": .green,
            "Z": .blue,
        ])
        .frame(height: 250)
        .onAppear {
            snapshotTask?.cancel()
            snapshotTask = Task {
                let interval: Duration = .milliseconds(90)
                while !Task.isCancelled {
                    await MainActor.run {
                        lastSnapshot = data.segments.map { Array($0.simds) }
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

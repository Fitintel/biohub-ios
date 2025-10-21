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
    @Bindable var data: DatedFloat3Segments
    @State private var lastSnapshot: [[DatedFloat3]] = []
    @State private var snapshotTask: Task<Void, Never>? = nil
    
    var body: some View {
        Chart {
            let segments: [[DatedFloat3]] = lastSnapshot
            ForEach(segments.indices, id:\.self) { (i: Int) in
                ForEach(segments[i]) { (point: DatedFloat3) in
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("X", point.read.x),
                             series: .value("Series", "X\(i)"))
                    .foregroundStyle(by: .value("Axis", "X"))
                }
            }
            ForEach(segments.indices, id:\.self) { (i: Int) in
                ForEach(segments[i]) { (point: DatedFloat3) in
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Y", point.read.y),
                             series: .value("Series", "Y\(i)"))
                    .foregroundStyle(by: .value("Axis", "Y"))
                }
            }
            ForEach(segments.indices, id:\.self) { (i: Int) in
                ForEach(segments[i]) { (point: DatedFloat3) in
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
                let interval: Duration = .milliseconds(150)
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

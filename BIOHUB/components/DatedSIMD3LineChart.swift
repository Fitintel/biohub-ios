//
//  DatedSIMD3ListView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import SwiftUI
import simd
import Charts

struct DatedSIMD3LineChart: View {
    
    let max: Float
    @Bindable var data: DatedSIMD3FSegments
    @State private var lastSnapshot: [[DatedSIMD3F]] = []
    @State private var timer: Timer? = nil
    private let refreshInterval = 1.0 / 20.0
    
    var body: some View {
        Chart {
            let segments: [[DatedSIMD3F]] = lastSnapshot
            ForEach(segments.indices, id:\.self) { i in
                ForEach(segments[i]) { point in
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("X", point.read.x),
                             series: .value("Series", "X-\(i)"))
                    .foregroundStyle(by: .value("Axis", "X"))
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Y", point.read.y),
                             series: .value("Series", "Y-\(i)"))
                    .foregroundStyle(by: .value("Axis", "Y"))
                    LineMark(x: .value("Time", point.readTime),
                             y: .value("Z", point.read.z),
                             series: .value("Series", "Z-\(i)"))
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
            timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
                lastSnapshot = data.segments.map { Array($0.simds) }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

//
//  RollingAverage.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-24.
//

import Observation
import Foundation

@Observable
public class RollingAverage {
    public private(set) var average: Double? = nil

    private var ptr: Int = 0
    private var values: [Double?]
    private let capacity: Int
    private var runningSum: Double = 0
    private var filledCount: Int = 0

    public init(keepCount: Int) {
        self.capacity = keepCount
        self.values = Array(repeating: nil, count: keepCount)
    }

    public func add(_ val: Double) {
        if let old = values[ptr] {
            runningSum -= old
        } else {
            filledCount += 1
        }

        // Insert the new value
        values[ptr] = val
        runningSum += val

        // Advance pointer
        ptr = (ptr + 1) % capacity

        // Update average
        if filledCount > 0 {
            average = runningSum / Double(filledCount)
        } else {
            average = nil
        }
    }
}

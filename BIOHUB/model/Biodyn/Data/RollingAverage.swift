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
    
    public var average: Double? = nil
    private var ptr: Int = 0
    private var values: [Double?]
    private let keeps: Int

    public init(keepCount: Int) {
        values = Array(repeating: nil, count: keepCount)
        keeps = keepCount
    }
    
    public func add(_ val: Double) {
        values[ptr] = val
        ptr = (ptr + 1) % keeps
        let hasValue = values.count(where: { x in x != nil })
        var sum: Double?
        for v in values {
            if v != nil && sum == nil {
                sum = v
            } else if v != nil {
                sum! += v!
            }
        }
        if hasValue != 0 && sum != nil {
            average = sum! / Double(hasValue)
        }
    }
}

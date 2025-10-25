//
//  PSelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public enum SelfTestState: UInt32 {
    case notStarted = 0
    case running = 1
    case completedWithError = 2
    case completedOk = 3
    case cancelled = 4
    case invalid = 5
}

public protocol PSelfTestService: Observable {
    var selfTestState: SelfTestState? { get }
    var selfTestError: String? { get }
    var ledValue: Bool? { get }

    func runSelfTest() async
    func read() async
    
    func writeLEDValue(value: Bool) async
    func readLEDValue() async
}

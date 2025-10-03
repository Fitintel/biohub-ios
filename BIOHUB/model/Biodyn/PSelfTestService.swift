//
//  PSelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public enum SelfTestState: Int32 {
    case notStarted = 0
    case running = 1
    case completedWithError = 2
    case completedOk = 3
    case cancelled = 4
}

public protocol PSelfTestService: Observable {
    var selfTestState: SelfTestState? { get }
    var selfTestError: String? { get }
    
    func runSelfTest()
}

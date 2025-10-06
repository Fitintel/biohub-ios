//
//  TestSelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestSelfTestService: PSelfTestService, TestWithDelays {
    var selfTestState: SelfTestState?
    var selfTestError: String?
    
    init() {
        doQuickly {
            self.selfTestState = SelfTestState.notStarted
        }
    }
    
    func runSelfTest() {
        doImmediately {
            self.selfTestState = SelfTestState.notStarted
        }
        doSoon {
            self.selfTestState = SelfTestState.running
        }
        doEventually {
            self.selfTestState = [SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedOk,
                                  SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.invalid].randomElement()!
            if self.selfTestState == SelfTestState.completedWithError {
                self.selfTestError = ["LED module failed", "IMU module failed", "EMG module failed", "Fast Data module failed", "Time Sync module failed", "Temp Module Failed"].randomElement()!
            }
        }
    }
    
    
}

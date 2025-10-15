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
    
    var sti: SelfTestState = SelfTestState.notStarted
    var ste: String = ""
    
    init() {
        doQuickly {
            self.selfTestState = SelfTestState.notStarted
        }
    }
    
    public func read() {
        doImmediately {
            self.selfTestState = self.sti
            self.selfTestError = self.ste
        }
    }
    
    func runSelfTest() {
        doImmediately {
            self.sti = SelfTestState.notStarted
        }
        doSoon {
            self.sti = SelfTestState.running
        }
        doEventually {
            self.sti = [SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedOk,
                                  SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.invalid].randomElement()!
            if self.sti == SelfTestState.completedWithError {
                self.ste = ["LED module failed", "IMU module failed", "EMG module failed", "Fast Data module failed", "Time Sync module failed", "Temp Module Failed"].randomElement()!
            }
        }
    }
    
    
}

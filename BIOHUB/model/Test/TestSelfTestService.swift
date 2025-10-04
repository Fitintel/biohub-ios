//
//  TestSelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestSelfTestService: PSelfTestService {
    var selfTestState: SelfTestState?
    var selfTestError: String?
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.9, 1.9].randomElement()!) {
            self.selfTestState = SelfTestState.notStarted
        }
    }
    
    func runSelfTest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2].randomElement()!) {
            self.selfTestState = SelfTestState.notStarted
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.5, 0.6].randomElement()!) {
            self.selfTestState = SelfTestState.running
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + [0.9, 1.9, 2, 2.5, 2.9, 3, 3.1, 3.2, 4, 5.5, 5].randomElement()!) {
            self.selfTestState = [SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedOk,
                                  SelfTestState.completedOk, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.completedWithError, SelfTestState.completedOk, SelfTestState.invalid].randomElement()!
            if self.selfTestState == SelfTestState.completedWithError {
                self.selfTestError = ["LED module failed", "IMU module failed", "EMG module failed", "Fast Data module failed", "Time Sync module failed", "Temp Module Failed"].randomElement()!
            }
        }
    }
    

}

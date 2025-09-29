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
    var selfTestOk: Bool?
    var selfTestError: String?
    
    init() {
    }
    
    func runSelfTest() {
        selfTestOk = nil
        selfTestError = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.9, 1.9, 2, 2.5, 2.9, 3, 3.1, 3.2, 4, 5.5, 5].randomElement()!) {
            self.selfTestOk = [true, true, true, true, false].randomElement()!
            if !self.selfTestOk! {
                self.selfTestError = ["Failed to init accelerometer", "Failed to read EMG", "Failed to set LED"].randomElement()!
            }
        }
    }
    

}

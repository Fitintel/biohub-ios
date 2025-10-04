//
//  TestTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation
import os.log

@Observable
class TestTestService: PTestService, TestWithDelays {
    
    var ledValue: Bool? = nil
    
    private var ledInternal: Bool = false
    
    init() {
    }
    
    func writeLEDValue(value: Bool) {
        ledInternal = value
        log.info("Beep boop testing setting the LED to \(value ? "on" : "off")")
    }
    
    func readLEDValue() {
        doAtSomePoint {
            self.ledValue = self.ledInternal
        }
    }
}

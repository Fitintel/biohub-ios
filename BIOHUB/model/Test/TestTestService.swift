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
class TestTestService: PTestService {
    
    var ledValue: Bool? = nil
    
    private var ledInternal: Bool = false
    
    init() {
    }
    
    func writeLEDValue(value: Bool) {
        ledInternal = value
        log.info("Beep boop testing setting the LED to \(value ? "on" : "off")")
    }
    
    func readLEDValue() {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.3, 0.4, 0.5, 0.9, 1.2, 2, 2.5].randomElement()!) {
            self.ledValue = self.ledInternal
        }
    }
}

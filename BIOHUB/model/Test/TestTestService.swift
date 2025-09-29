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
    var deviceName: String? = nil
    var ledValue: Bool? = nil
    
    init(deviceName: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.3, 0.4, 0.5, 0.9, 1.2, 2, 2.5].randomElement()!) {
            self.deviceName = deviceName
        }
    }
    
    func writeLEDValue(value: Bool) {
        ledValue = value
        log.info("Beep boop testing setting the LED to \(value ? "on" : "off")")
    }
}

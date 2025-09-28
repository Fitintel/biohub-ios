//
//  TestTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import os.log

@Observable
class TestTestService: PTestService {
    func writeLEDValue(value: Bool) {
        log.info("Beep boop testing setting the LED to \(value ? "on" : "off")")
    }
}

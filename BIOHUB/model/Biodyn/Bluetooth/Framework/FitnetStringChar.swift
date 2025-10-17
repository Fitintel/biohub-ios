//
//  FitnetStringChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-02.
//

import Foundation
import Observation
import CoreBluetooth

// Read-only string characteristic
@Observable
public class FitnetStringChar: FitnetBLEChar {
    var value: String? = nil
    
    public override func onRead(_ data: Data) {
        self.value = String(data: data, encoding: .ascii)
        log.info("[\(self.name)] Read \"\(self.value ?? "nil")\"")
    }
    
    public override func writeValue(data: Data, type: CBCharacteristicWriteType) {
        log.error("[\(self.name)] Cannot write to read-only char")
    }
}

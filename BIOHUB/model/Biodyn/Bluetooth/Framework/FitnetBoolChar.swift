//
//  FitnetBoolChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-23.
//

import CoreBluetooth
import Observation

// Read/write bool char
@Observable
public class FitnetBoolChar : FitnetBLEChar {
    public var value: Bool?
    
    public override func onRead(_ data: Data) {
        value = data.first! > 0
    }
    
    public func writeValue(_ value: Bool) {
        writeValue(data: Data([UInt8]([value ? 1 : 0])), type: .withResponse)
    }
}

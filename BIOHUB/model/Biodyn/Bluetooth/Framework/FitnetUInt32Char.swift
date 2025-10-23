//
//  FitnetUInt32Char.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-23.
//

import Foundation
import Observation
import CoreBluetooth

// Read/write UInt32 char
@Observable
public class FitnetUInt32Char: FitnetBLEChar {
    var value: UInt32? = nil
    
    public override func onRead(_ data: Data) {
        self.value = data.withUnsafeBytes { ptr in
            ptr.load(as: UInt32.self)
        }
    }
    
    public func writeValue(_ value: UInt32) {
        var v = value
        writeValue(data: withUnsafeBytes(of: &v) { Data($0) },
                   type: .withResponse)
    }
    
}

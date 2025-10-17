//
//  FitnetFloatChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import Foundation
import Observation
import CoreBluetooth
import simd

// Read-only float3 characteristic
@Observable
public class FitnetFloatChar: FitnetBLEChar {
    var value: Float?
    
    public override func onLoaded() {
        // No eager read
    }
    
    public override func onRead(_ data: Data) {
        // Convert data to float array
        let floatArray = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self), count: 1))
        }
        
        // Check we have enough data
        if floatArray.count < 1 {
            log.error("[\(self.name)] Got \(floatArray.count) floats for single float data read")
            return
        }
        
        // Convert float array to Float
        self.value = floatArray[0]
    }
    
    public override func writeValue(data: Data, type: CBCharacteristicWriteType) {
        log.error("[\(self.name)] Cannot write to read-only char")
    }
}

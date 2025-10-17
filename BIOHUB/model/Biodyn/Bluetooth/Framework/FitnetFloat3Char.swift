//
//  FitnetFloat3Char.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Foundation
import Observation
import CoreBluetooth
import simd

// Read-only float3 characteristic
@Observable
public class FitnetFloat3Char: FitnetBLEChar {
    var value: SIMD3<Float>?
    
    public override func onLoaded() {
        // No eageer read
    }
    
    public override func onRead(_ data: Data) {
        // Convert data to float array
        let floatArray = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self), count: data.count / MemoryLayout<Float>.stride))
        }
        
        // Check we have enough data
        if floatArray.count < 3 {
            log.error("[\(self.name)] Got \(floatArray.count) floats for float3 data read")
            return
        }
        
        // Convert float array to SIMD3<Float>
        self.value = SIMD3<Float>([floatArray[0], floatArray[1], floatArray[2]])
    }
    
    public override func writeValue(data: Data, type: CBCharacteristicWriteType) {
        log.error("[\(self.name)] Cannot write to read-only char")
    }
}

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
    
    public func writeValueAsync(_ value: UInt32) async -> BleWriteResult {
        var v = value
        return await writeValueAsync(data: withUnsafeBytes(of: &v) { Data($0) }, timeout: .milliseconds(400))
    }
    
}

// Read/write UInt64 char
@Observable
public class FitnetUInt64Char: FitnetBLEChar {
    var value: UInt64? = nil
    
    public override func onRead(_ data: Data) {
        self.value = data.withUnsafeBytes { ptr in
            ptr.load(as: UInt64.self)
        }
    }
    
    public func writeValueAsync(_ value: UInt64) async -> BleWriteResult {
        var v = value
        return await writeValueAsync(data: withUnsafeBytes(of: &v) { Data($0) }, timeout: .milliseconds(400))
    }
    
}

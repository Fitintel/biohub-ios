//
//  FitnetStringChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-02.
//

import Foundation
import Observation

// Read-only string characteristic
@Observable
public class FitnetStringChar: FitnetBLEChar {
    var value: String? = nil
    
    public override func onRead(_ data: Data) {
        self.value = String(data: data, encoding: .ascii)
    }
}

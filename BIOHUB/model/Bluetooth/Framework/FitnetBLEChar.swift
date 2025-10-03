//
//  FitnetBLEChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-02.
//

import CoreBluetooth
import Observation

@Observable
public class FitnetBLEChar: Observable {
    var name: String
    var uuid: CBUUID
    var loaded: Bool
    var cbChar: CBCharacteristic?
    var peripheral: CBPeripheral
    
    init(_ peripheral: CBPeripheral, _ name: String, _ uuid: CBUUID) {
        self.name = name
        self.uuid = uuid
        self.loaded = false
        self.cbChar = nil
        self.peripheral = peripheral
    }
    
    // Callback when loaded. Default behaviour is to read the char value
    open func onLoaded() {
        self.readValue()
    }
    
    // Callback with data read from this characteristic
    open func onRead(_ data: Data) {}
    
    func writeValue(data: Data, type: CBCharacteristicWriteType) {
        if !self.loaded {
            log.error("[\(self.name)] Attempted to write value of unloaded characteristic")
            return
        }
        peripheral.writeValue(data, for: self.cbChar!, type: .withResponse)
    }
    
    func readValue() {
        if !self.loaded {
            log.error("[\(self.name)] Attempted to read value of unloaded characteristic")
            return
        }
        peripheral.readValue(for: self.cbChar!)
    }
}

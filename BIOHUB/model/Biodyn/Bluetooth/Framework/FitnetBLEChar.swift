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
    var uuid: CBUUID // BLE UUID
    var loaded: Bool
    var cbChar: CBCharacteristic?
    var peripheral: CBPeripheral
    
    // To catch when readValue is overwritten to see if readValueAsync should run
    private var didRequestRead: Bool = false
    
    private var readCont: CheckedContinuation<Data, Never>?
    
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
    
    // Client callback with data read from this characteristic
    open func onRead(_ data: Data) {}
    
    // Callback with data read from this characteristic
    final func onReadInternal(_ data: Data) {
        onRead(data)
        if readCont != nil {
            readCont?.resume(returning: data)
        }
    }
    
    func writeValue(data: Data, type: CBCharacteristicWriteType) {
        if !self.loaded {
            log.error("[\(self.name)] Attempted to write value of unloaded characteristic")
            return
        }
        peripheral.writeValue(data, for: self.cbChar!, type: .withResponse)
    }
    
    func readValue() {
        didRequestRead = false
        if !self.loaded {
            log.error("[\(self.name)] Attempted to read value of unloaded characteristic")
            return
        }
        didRequestRead = true
        peripheral.readValue(for: self.cbChar!)
    }
    
    // Waits for read value
    func readValueAsync(timeout: Duration) async -> Void {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    self.readValue()
                    if !self.didRequestRead { return }
                    let _ = await withCheckedContinuation { cont in
                        self.readCont = cont
                    }
                }
                
                group.addTask {
                    try await Task.sleep(for: timeout)
                    return
                }
                
                let _ = try await group.next()!
                group.cancelAll()
            }
        }
        catch {
            log.error("[\(self.name)] Error in readValueAsync: \(error.localizedDescription)")
        }
    }
}

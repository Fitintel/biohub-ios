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
    
    private enum TimeoutError: Error { case timeout }
    
    // To catch when readValue is overwritten to see if readValueAsync should run
    private var didRequestRead: Bool = false
    
    private var readCont: CheckedContinuation<Data, Error>?
    
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
        if let cont = readCont {
            readCont = nil
            cont.resume(returning: data)
        }
    }
    
    func writeValue(data: Data, type: CBCharacteristicWriteType) {
        guard self.loaded else {
            log.error("[\(self.name)] Attempted to write value of unloaded characteristic")
            return
        }
        peripheral.writeValue(data, for: self.cbChar!, type: type)
    }
    
    func readValue() {
        didRequestRead = false
        guard self.loaded else {
            log.error("[\(self.name)] Attempted to read value of unloaded characteristic")
            return
        }
        didRequestRead = true
        peripheral.readValue(for: self.cbChar!)
    }
    
    // Waits for read value
    func readValueAsync(timeout: Duration) async {
        guard self.loaded else {
            log.error("[\(self.name)] Attempted to read value of unloaded characteristic")
            return
        }
        precondition(readCont == nil, "[\(name)] Concurrent read/write async calls are not supported")

        readValue()
        
        // Start a cancelable timeout that races the read
        let timeoutTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self = self else { return }
            if let cont = self.readCont {
                self.readCont = nil
                cont.resume(throwing: TimeoutError.timeout)
            }
        }
        defer { timeoutTask.cancel() }

        do {
            let _ = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
                self.readCont = cont
            }
        }
        catch {
            log.error("[\(self.name)] Failed to read async: \(error.localizedDescription)")
        }
        
    }
}

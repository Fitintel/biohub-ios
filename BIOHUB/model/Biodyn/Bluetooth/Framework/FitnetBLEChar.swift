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
    public private(set)var readTime: TimeInterval = 0
    
    // To catch when readValue is overwritten to see if readValueAsync should run
    private var didRequestRead: Bool = false
    private var startRead: Date = Date.now
    
    private enum BleResult { case timeout, writeConfirmation, read(Data) }
    private var bleCont: CheckedContinuation<BleResult, Error>?
    private var contLock = NSLock()
    
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
    open func onWrite() {}
    
    // Callback with data read from this characteristic
    final func onReadInternal(_ data: Data) {
        readTime = Date.now.timeIntervalSince(startRead)
        onRead(data)
        resume(.read(data))
    }
    
    final func onWriteInternal() {
        onWrite()
        resume(.writeConfirmation)
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
        startRead = Date.now
        didRequestRead = true
        peripheral.readValue(for: self.cbChar!)
    }
    
    // Waits for written value
    func writeValueAsync(data: Data, timeout: Duration) async {
        guard checkWR() else { return }
        writeValue(data: data, type: .withResponse)
        let res = await bleNotif("write", timeout)
        if res != nil {
            if case .writeConfirmation = res {
                return
            }
            log.error("[\(self.name)] Got a non-write response in writeValueAsync!")
        }
    }
    
    // Waits for read value
    func readValueAsync(timeout: Duration) async {
        guard checkWR() else { return }
        readValue()
        let res = await bleNotif("read", timeout)
        if res != nil {
            if case .read(_) = res {
                return
            }
            log.error("[\(self.name)] Got a non-read response in readValueAsync!")
        }
    }
    
    // Ensures that reading/writing is allowed
    private func checkWR() -> Bool {
        guard self.loaded else {
            log.error("[\(self.name)] Attempted to write value of unloaded characteristic")
            return false
        }
        guard self.bleCont == nil else {
            log.error("[\(self.name)] Attempted to read already reading/writing characteristic")
            return false
        }
        return true
    }
    
    private func bleNotif(_ op: String, _ timeout: Duration) async -> BleResult? {
        // Start a cancelable timeout that races the read
        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self = self else { return }
            self.resume(.timeout)
        }
        defer { timeoutTask.cancel() }
        do {
            let res = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<BleResult, Error>) in
                self.bleCont = cont
            }
            if case .timeout = res {
                log.warning("[\(self.name)] Failed to \(op) async: timed out")
                return nil
            }
            return res
        } catch {
            log.error("[\(self.name)] Failed to \(op) async: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func takeCont() -> CheckedContinuation<BleResult, Error>? {
        contLock.lock(); defer { contLock.unlock() }
        let c = bleCont
        bleCont = nil
        return c
    }
    
    private func resume(_ r: BleResult) {
        guard let c = takeCont() else { return }
        c.resume(returning: r);
    }
}

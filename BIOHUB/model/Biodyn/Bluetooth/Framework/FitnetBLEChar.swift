//
//  FitnetBLEChar.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-02.
//

import CoreBluetooth
import Observation
import Synchronization


// BLE read result types
public enum BleReadResult { case unloaded, timeout, invalid, read(Data) }
// BLE write result types
public enum BleWriteResult { case unloaded, timeout, invalid, written }

private protocol BleCharState {
    var name: String { get }
    
    func onReadInternal(_ data: Data) -> BleCharState
    func onWriteInternal() -> BleCharState
    func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult
    func readValueAsync(timeout: Duration) async -> BleReadResult
}

// A BLE char with async/await support for reads and writes
// -> Concurrent reads are supported, and will take the earliest returned read
// -> Concurrent writes are disallowed
// -> If trying to write while reading, we wait for read to complete
// -> If trying to read while writing, we wait for write complete
@Observable
public class FitnetBLEChar: Observable {
    public let name: String // Characteristic name
    public let uuid: CBUUID // Characteristic BLE UUID
    public var loaded: Bool { get { cbChar != nil } } // Whether this characteristic has been loaded
    public var cbChar: CBCharacteristic? = nil // Underlying CoreBluetooth characteristic
    public let peripheral: CBPeripheral // Underlying CoreBluetooth peripheral
    
    fileprivate var startRead: Date? // Last read time start
    public fileprivate(set)var readTime: TimeInterval? // Time last read took
    public fileprivate(set)var writeTime: TimeInterval? // Time last write took
    fileprivate var startWrite: Date? // Last write time start

    // WARNING: take care of mutex acquisition order to avoid deadlocks.
    // Allow read, write, or idle. Not multiple at same time.
    fileprivate let stateMux: Mutex<BleCharState?> = Mutex(nil)
    // Continuations waiting on a read
    fileprivate let readContsMux: Mutex<[CheckedContinuation<BleReadResult, Never>]> = Mutex([])
    // Continuations waiting on a write
    fileprivate let writeContsMux: Mutex<[CheckedContinuation<BleWriteResult, Never>]> = Mutex([])

    init(_ peripheral: CBPeripheral, _ name: String, _ uuid: CBUUID) {
        self.name = name
        self.uuid = uuid
        self.peripheral = peripheral
    }
    
    // Client callback when loaded. Default behaviour is to read the char value.
    open func onLoaded() {
        Task { await self.readValueAsync(timeout: .seconds(1.5)) }
    }
    // Client callback with data read from this characteristic
    open func onRead(_ data: Data) {}
    // Client callback that data was written to this characteristic
    open func onWrite() {}
    
    // Called by system when a read is completed
    final func onReadInternal(_ data: Data) {
        stateMux.withLock { state in
            guard state != nil else {
                log.error("[\(self.name)] Read data recieved while there was no state")
                return
            }
            state = state!.onReadInternal(data)
        }
    }
    
    // Called by system when a write is completed
    final func onWriteInternal() {
        stateMux.withLock { state in
            guard state != nil else {
                log.error("[\(self.name)] Confirmed written while there was no state")
                return
            }
            state = state!.onWriteInternal()
        }
    }
    
    // Waits until characteristic write completes
    func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult {
        guard loaded("write") else { return .unloaded } // Ensure char is loaded
        // Ensure we have a value
        let state = stateMux.withLock { state in
            if state == nil { state = BleCharIsIdle(self) }
            return state
        }
        let res = await state!.writeValueAsync(data: data, timeout: timeout)
        switch res {
        case .invalid: log.error("[\(self.name)] Invalid write")
        case .timeout: log.warning("[\(self.name)] Write timed out")
        default: break
        }
        return res
    }
    
    // Waits until characteristic read completes
    func readValueAsync(timeout: Duration) async -> BleReadResult {
        guard loaded("read") else { return .unloaded } // Ensure char is loaded
        // Ensure we have a value
        let state = stateMux.withLock { state in
            if state == nil { state = BleCharIsIdle(self) }
            return state
        }
        let res = await state!.readValueAsync(timeout: timeout)
        switch res {
        case .invalid: log.error("[\(self.name)] Invalid read")
        case .timeout: log.warning("[\(self.name)] Read timed out")
        default: break
        }
        return res
    }
    
    // Ensures that char is loaded, prints message if not
    private func loaded(_ op: String) -> Bool {
        guard self.loaded else {
            log.error("[\(self.name)] Attempted to \(op) value of unloaded characteristic")
            return false
        }
        return true
    }
    
    // Resume all taken write continuations with the given results
    fileprivate func resumeWrite(_ r: BleWriteResult) {
        // Resume conts
        writeContsMux.withLock { conts in
            for cont in conts {
                cont.resume(returning: r)
            }
            conts.removeAll()
        }
    }
    
    // Resume all taken read continuations with the given results
    fileprivate func resumeRead(_ r: BleReadResult) {
        // Resume conts
        readContsMux.withLock { conts in
            for cont in conts {
                cont.resume(returning: r)
            }
            conts.removeAll()
        }
    }

}

@Observable
private class BleCharIsReading: BleCharState {
    var name: String { get { owner.name } }
    let owner: FitnetBLEChar // Owner for state machine paradigm
    
    init(_ owner: FitnetBLEChar) {
        self.owner = owner
        owner.startRead = Date.now
    }
    
    func onReadInternal(_ data: Data) -> BleCharState {
        if let reqestTime = owner.startRead {
            owner.readTime = Date.now.timeIntervalSince(reqestTime) // Measure time it took to read
        } else {
            log.warning("[\(self.name)] Read time was not set, but got a read response") // No read start time?
        }
        owner.onRead(data) // Process read
        owner.resumeRead(.read(data)) // Send result to continuations
        return BleCharIsIdle(owner)
    }
    
    func onWriteInternal() -> BleCharState {
        log.error("[\(self.name)] Got write response while reading")
        return self
    }
    
    func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult {
        log.warning("[\(self.name)] Can't write while reading")
        // TODO: Queue this write operation
        return .invalid
    }
    
    func readValueAsync(timeout: Duration) async -> BleReadResult {
//        log.debug("[\(self.name)] Doubled up read")
        // Start a cancelable timeout that races the read
        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self = self else { return }
            self.owner.resumeRead(.timeout)
        }
        defer { timeoutTask.cancel() }
        
        // We're already reading, add continuation
        return await withCheckedContinuation { (cont: CheckedContinuation<BleReadResult, Never>) in
            owner.readContsMux.withLock { conts in
                conts.append(cont)
            }
        }
    }
    
}


@Observable
private class BleCharIsWriting: BleCharState {
    var name: String { get { owner.name } }
    var owner: FitnetBLEChar // Owner for state machine paradigm
    
    init(_ owner: FitnetBLEChar) {
        self.owner = owner
        owner.startWrite = Date.now
    }
    
    func onReadInternal(_ data: Data) -> BleCharState {
        log.warning("[\(self.name)] Got read response while writing")
        return self
    }
    
    // State called by owner, returns new state
    func onWriteInternal() -> BleCharState {
        if let reqestTime = owner.startWrite {
            owner.writeTime = Date.now.timeIntervalSince(reqestTime) // Measure time it took to read
        } else {
            log.warning("[\(self.name)] Read time was not set, but got a read response") // No read start time?
        }
        owner.onWrite() // Process read
        owner.resumeWrite(.written) // Send result to continuations
        return BleCharIsIdle(owner)
    }
    
    func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult {
        log.warning("[\(self.name)] Can't re-write while writing")
        return .invalid
    }
    
    func readValueAsync(timeout: Duration) async -> BleReadResult {
        log.warning("[\(self.name)] Can't read while writing")
        // TODO: Queue this read operation
        return .invalid
    }
}





@Observable
private class BleCharIsIdle: BleCharState {
    var name: String { get { owner.name } }
    var owner: FitnetBLEChar
    
    init(_ owner: FitnetBLEChar) { self.owner = owner }
    
    func onReadInternal(_ data: Data) -> BleCharState {
        log.warning("[\(self.name)] Got read result while idle")
        return self
    }
    
    func onWriteInternal() -> BleCharState {
        log.warning("[\(self.name)] Got write confirmation while idle")
        return self
    }
    
    // Called by owner
    func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult {
        // Set owner state to writing
        owner.stateMux.withLock { (state: inout BleCharState?) in
            state = BleCharIsWriting(owner)
        }
        // Start a cancelable timeout that races the write
        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self = self else { return }
            self.owner.resumeRead(.timeout)
        }
        defer { timeoutTask.cancel() }
        
        // Add cont and write
        return await withCheckedContinuation { (cont: CheckedContinuation<BleWriteResult, Never>) in
            owner.writeContsMux.withLock { conts in
                conts.append(cont)
                owner.peripheral.writeValue(data, for: owner.cbChar!, type: .withResponse)
            }
        }
    }
    
    // Called by owner
    func readValueAsync(timeout: Duration) async -> BleReadResult {
        // Set owner state to reading, check if someone beat us here
        let beat = owner.stateMux.withLock { (state: inout BleCharState?) in
            if state is BleCharIsIdle {
                state = BleCharIsReading(owner)
                return false
            } else { // Someone beat us here
                return true
            }
        }
        // If we were beat here, delegate back to correct handler
        if beat {
            return await owner.stateMux.withLock { $0 }!.readValueAsync(timeout: timeout)
        }
        // Start a cancelable timeout that races the read
        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self = self else { return }
            self.owner.resumeRead(.timeout)
        }
        defer { timeoutTask.cancel() }
        
        // Add cont and read
        return await withCheckedContinuation { (cont: CheckedContinuation<BleReadResult, Never>) in
            owner.readContsMux.withLock { conts in
                conts.append(cont)
                owner.peripheral.readValue(for: owner.cbChar!)
            }
        }
    }
    
}

//
//  SelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import CoreBluetooth

@Observable
public class SelfTestService: FitnetBLEService, PSelfTestService {
    private static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0xA9, 0x12])))
    private static let SELF_TEST_STATE_UUID = CBUUID(data: Data([UInt8]([0x1A, 0x10])))
    private static let SELF_TEST_MSG_UUID = CBUUID(data: Data([UInt8]([0x1A, 0x11])))
    private static let SELF_TEST_LED = CBUUID(data: Data([UInt8]([0x1A, 0x12])))

    public var selfTestState: SelfTestState? { get { stateChar.state } }
    public var selfTestError: String? { get { errMsgChar.value } }
    public var ledValue: Bool? { get { ledControlChar.value } }
    
    private let stateChar: SelfTestStateChar
    private let errMsgChar: FitnetStringChar
    private let ledControlChar: FitnetBoolChar
    
    init(_ peripheral: CBPeripheral) {
        let state = SelfTestStateChar(peripheral)
        self.stateChar = state
        
        let msg = FitnetStringChar(peripheral, "Self Test Message", Self.SELF_TEST_MSG_UUID)
        msg.print = false
        self.errMsgChar = msg
        
        let led = FitnetBoolChar(peripheral, "LED State", Self.SELF_TEST_LED)
        self.ledControlChar = led
        
        super.init(peripheral,
                   name: "Self Test Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [state, msg, led])
    }
    
    public func read() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.stateChar.readValueAsync(timeout: .milliseconds(400))
            }
            group.addTask {
                await self.errMsgChar.readValueAsync(timeout: .milliseconds(400))
            }
            group.addTask {
                await self.ledControlChar.readValueAsync(timeout: .milliseconds(400))
            }
            await group.waitForAll()
        }
    }
    
    public func runSelfTest() async {
        if selfTestState == SelfTestState.running {
            log.warning("[\(self.name)] Tried to start already-running self-test")
            return
        }
        self.stateChar.state = SelfTestState.notStarted
        await stateChar.write(state: SelfTestState.running)
    }
    
    // Writes the LED value
    public func writeLEDValue(value: Bool) async {
        await ledControlChar.writeValueAsync(data: Data([UInt8]([value ? 1 : 0])),
                                             timeout: .milliseconds(2000))
    }
    
    // Reads LED value
    public func readLEDValue() async { await ledControlChar.readValueAsync(timeout: .milliseconds(400)) }

    @Observable
    private class SelfTestStateChar: FitnetBLEChar {
        
        public var state: SelfTestState? = nil
        
        init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Self Test State", SELF_TEST_STATE_UUID)
        }
        
        func write(state: SelfTestState) async {
            if state != SelfTestState.cancelled && state != SelfTestState.running {
                log.error("[\(self.name)] Can only cancel or start running self-test, got \(state.rawValue)")
                return
            }
            
            var data = Data()
            withUnsafeBytes(of: state.rawValue) { data.append(contentsOf: $0) }
            await super.writeValueAsync(data: data, timeout: .milliseconds(400))
        }
        
        override func onRead(_ data: Data) {
            if data.count != 4 {
                log.error("[\(self.name)] Failed to read state: len \(data.count)")
                return
            }
            let intData = data.withUnsafeBytes({ ptr in
                return ptr.load(as: UInt32.self)
            })
            if intData > SelfTestState.cancelled.rawValue {
                log.error("[\(self.name)] Self test state was outside bounds: \(intData)")
                state = SelfTestState.invalid
            } else {
                state = SelfTestState(rawValue: intData)
            }
        }
    }

}

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

    public var selfTestState: SelfTestState? { get { stateChar.state } }
    public var selfTestError: String? { get { errMsgChar.value } }
    
    private let stateChar: SelfTestStateChar
    private let errMsgChar: FitnetStringChar
    
    init(_ peripheral: CBPeripheral) {
        let state = SelfTestStateChar(peripheral)
        self.stateChar = state
        
        let msg = FitnetStringChar(peripheral, "Self Test Message", Self.SELF_TEST_MSG_UUID)
        self.errMsgChar = msg
        
        super.init(peripheral,
                   name: "Self Test Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [state, msg])
    }
    
    public func read() {
        stateChar.readValue()
        errMsgChar.readValue()
    }
    
    public func runSelfTest() {
        if selfTestState == SelfTestState.running {
            log.warning("[\(self.name)] Tried to start already-running self-test")
            return
        }
        stateChar.write(state: SelfTestState.running)
    }
    
    @Observable
    private class SelfTestStateChar: FitnetBLEChar {
        
        public var state: SelfTestState? = nil
        
        init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Self Test State", SELF_TEST_STATE_UUID)
        }
        
        func write(state: SelfTestState) {
            if state != SelfTestState.cancelled && state != SelfTestState.running {
                log.error("[\(self.name)] Can only cancel or start running self-test, got \(state.rawValue)")
                return
            }
            
            var data = Data()
            withUnsafeBytes(of: state.rawValue) { data.append(contentsOf: $0) }
            super.writeValue(data: data, type: .withResponse)
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

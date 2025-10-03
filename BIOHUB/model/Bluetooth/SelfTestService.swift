//
//  SelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import CoreBluetooth

// TODO: implement this class
@Observable
public class SelfTestService: FitnetBLEService, PSelfTestService {
    public var selfTestState: SelfTestState?
    public var selfTestError: String?
    
    init(_ peripheral: CBPeripheral) {
        super.init(peripheral,
                   name: "Self Test Service",
                   uuid: CBUUID(data: Data([UInt8]([0xA9, 0x12].reversed()))),
                   characteristics: [])
    }
    
    public func runSelfTest() {
    }

}

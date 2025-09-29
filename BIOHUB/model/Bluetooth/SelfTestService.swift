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
public class SelfTestService: FitnetPeripheralService, PSelfTestService {
    
    static let TAG = "SelfTestService"
    
    public var selfTestOk: Bool?
    public var selfTestError: String?
    
    public func runSelfTest() {
    }

    public func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        return false
    }
    
    public func loadService(_ service: CBService) -> Bool {
        return false
    }
    
    public func notifyRead(_ char: CBCharacteristic) -> Bool {
        return false
    }

}

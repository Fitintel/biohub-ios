//
//  FitnetServices.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth
import SwiftUI
import Observation

@Observable
public class Biodyn: FitnetPeripheralService, PBiodyn {
    public typealias TTest = TestService
    public typealias TDeviceInfo = DeviceInformationService
    public typealias TSelfTest = SelfTestService
    
    public let uuid: UUID = UUID()
    
    public let deviceInfoService: DeviceInformationService
    public let testService: TestService
    public let selfTestService: SelfTestService
    

    // Connected peripheral
    let peripheral: CBPeripheral

    // All services. Put more frequently used services at the start
    let allServices: [any FitnetPeripheralService]
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        let deviceInfoService = DeviceInformationService(peripheral)
        self.deviceInfoService = deviceInfoService
        
        let testService = TestService(peripheral)
        self.testService = testService
        
        let selfTestService = SelfTestService()
        self.selfTestService = selfTestService
        
        self.allServices = [deviceInfoService, testService, selfTestService]
    }
    
    // Called when a service is discovered
    public func loadService(_ service: CBService) -> Bool {
        for s in allServices {
            if s.loadService(service) {
                return true
            }
        }
        return false
    }
    
    // Called when a characteristic is discovered
    public func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        for s in allServices {
            if s.loadCharacteristic(char) {
                return true
            }
        }
        return false
    }
    
    // Called when a read is done
    public func notifyRead(_ char: CBCharacteristic) -> Bool {
        for s in allServices {
            if s.notifyRead(char) {
                return true
            }
        }
        return false
    }
    
}

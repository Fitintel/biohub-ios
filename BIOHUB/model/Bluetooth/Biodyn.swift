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
class Biodyn: FitnetPeripheralService, PBiodyn {
    typealias TTest = TestService
    typealias TDeviceInfo = DeviceInformationService
    
    let uuid: UUID = UUID()
    
    // Device information service
    let deviceInfoService: DeviceInformationService
    
    // Test service
    let testService: TestService
    
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
        
        self.allServices = [deviceInfoService, testService]
    }
    
    // Called when a service is discovered
    func loadService(_ service: CBService) -> Bool {
        for s in allServices {
            if s.loadService(service) {
                return true
            }
        }
        return false
    }
    
    // Called when a characteristic is discovered
    func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        for s in allServices {
            if s.loadCharacteristic(char) {
                return true
            }
        }
        return false
    }
    
    // Called when a read is done
    func notifyRead(_ char: CBCharacteristic) -> Bool {
        for s in allServices {
            if s.notifyRead(char) {
                return true
            }
        }
        return false
    }
    
}

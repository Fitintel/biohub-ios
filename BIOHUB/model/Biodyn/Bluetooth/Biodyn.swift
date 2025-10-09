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
public class Biodyn: PBiodyn {
    public typealias TTest = TestService
    public typealias TDeviceInfo = DeviceInformationService
    public typealias TSelfTest = SelfTestService
    public typealias TIMU = IMUService
    public typealias TEMG = EMGService
    public typealias TDataFast = DataFastService

    private static let TAG = "Biodyn"
    
    public let uuid: UUID = UUID()
    
    public let deviceInfoService: DeviceInformationService
    public let testService: TestService
    public let selfTestService: SelfTestService
    public var imuService: IMUService
    public var emgService: EMGService
    public var dfService: DataFastService

    // Connected peripheral
    let peripheral: CBPeripheral

    let allServices: [FitnetBLEService]
    var serviceMap = Dictionary<CBUUID, FitnetBLEService>();
    var charServMap = Dictionary<CBUUID, FitnetBLEService>();
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        let deviceInfoService = DeviceInformationService(peripheral)
        self.deviceInfoService = deviceInfoService
        
        let testService = TestService(peripheral)
        self.testService = testService
        
        let selfTestService = SelfTestService(peripheral)
        self.selfTestService = selfTestService
        
        let imuService = IMUService(peripheral)
        self.imuService = imuService
        
        let emgService = EMGService(peripheral)
        self.emgService = emgService
        
        let dfService = DataFastService(peripheral)
        self.dfService = dfService
        
        self.allServices = [dfService, deviceInfoService, testService, selfTestService, imuService, emgService]
        for s in self.allServices {
            self.serviceMap.updateValue(s, forKey: s.uuid)
            for c in s.characteristics {
                self.charServMap.updateValue(s, forKey: c.uuid)
            }
        }
    }
    
    public func loadService(_ service: CBService) {
        guard let s = serviceMap[service.uuid] else {
            log.error("[\(Self.TAG)] Tried to load non-biodyn service \(service.uuid)")
            return
        }
        if !s.loadService(service) {
            log.error("[\(Self.TAG)] Matched service UUID failed to load \(s.uuid)")
            return
        }
    }
    
    public func loadCharacteristic(_ forService: CBService, _ char: CBCharacteristic) {
        guard let s = serviceMap[forService.uuid] else {
            log.error("[\(Self.TAG)] Tried to load characteristic for non-biodyn service \(forService.uuid)")
            return
        }
        if !s.loadCharacteristic(char) {
            log.error("[\(Self.TAG)] Service \(forService.uuid) failed to load characteristic \(char.uuid)")
        }
    }
    
    public func notifyRead(_ forCharacteristic: CBCharacteristic) {
        guard let s = serviceMap[forCharacteristic.uuid] else {
            log.error("[\(Self.TAG)] Could not find characteristic \(forCharacteristic.uuid)")
            return
        }
        if !s.notifyRead(forCharacteristic) {
            log.error("[\(Self.TAG)] Characteristic read \(forCharacteristic.uuid) in \(s.name) failed")
        }
    }
    
}

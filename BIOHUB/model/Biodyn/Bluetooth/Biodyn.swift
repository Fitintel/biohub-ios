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
    public typealias TDeviceInfo = DeviceInformationService
    public typealias TSelfTest = SelfTestService
    public typealias TDataFast = DataFastService

    private static let TAG = "Biodyn"
    
    public let uuid: UUID
    public let deviceInfoService: DeviceInformationService
    public let selfTestService: SelfTestService
    public var dfService: DataFastService
    public var avgReadDelay: Double? { get { return averageRead.average } }

    // Connected peripheral
    let peripheral: CBPeripheral

    public let allServices: [FitnetBLEService]
    public private(set)var serviceMap = Dictionary<CBUUID, FitnetBLEService>();
    public private(set)var charServMap = Dictionary<CBUUID, FitnetBLEService>();
    private let averageRead = RollingAverage(keepCount: 40)

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.uuid = peripheral.identifier
        
        let deviceInfoService = DeviceInformationService(peripheral)
        self.deviceInfoService = deviceInfoService
        
        let selfTestService = SelfTestService(peripheral)
        self.selfTestService = selfTestService
        
        let dfService = DataFastService(peripheral)
        self.dfService = dfService
        
        self.allServices = [dfService, deviceInfoService, selfTestService]
        for s in self.allServices {
            self.serviceMap.updateValue(s, forKey: s.uuid)
            for c in s.characteristics {
                self.charServMap.updateValue(s, forKey: c.uuid)
            }
        }
    }
    
    public func loadService(_ service: CBService) {
        guard let s = serviceMap[service.uuid] else {
            log.error("[\(Self.TAG)] Tried to load non-biodyn service \(service.uuid): valid are \(self.serviceMap.keys)")
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
        charServMap.updateValue(serviceMap[forService.uuid]!, forKey: char.uuid)
    }
    
    public func notifyRead(_ forCharacteristic: CBCharacteristic) {
        guard let s = charServMap[forCharacteristic.uuid] else {
            log.error("[\(Self.TAG)] Could not find characteristic \(forCharacteristic.uuid)")
            return
        }
        if !s.notifyRead(forCharacteristic) {
            log.error("[\(Self.TAG)] Characteristic read \(forCharacteristic.uuid) in \(s.name) failed")
            return
        }
        let delay = s.characteristicsMap[forCharacteristic.uuid]!.readTime
        averageRead.add(delay * 1000)
    }
    
    public func notifyWrite(_ forCharacteristic: CBCharacteristic) {
        guard let s = charServMap[forCharacteristic.uuid] else {
            log.error("[\(Self.TAG)] Could not find characteristic \(forCharacteristic.uuid)")
            return
        }
        if !s.notifyWrite(forCharacteristic) {
            log.error("[\(Self.TAG)] Characteristic write \(forCharacteristic.uuid) in \(s.name) failed")
            return
        }
    }
    
}

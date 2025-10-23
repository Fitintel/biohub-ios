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
    public static let READ_AVG_KEEPS: Int = 50
    private var readAvgPtr: Int = 0
    
    public let uuid: UUID
    
    public let deviceInfoService: DeviceInformationService
    public let selfTestService: SelfTestService
    public var dfService: DataFastService
    public var avgReadDelay: Double = 0

    // Connected peripheral
    let peripheral: CBPeripheral

    let allServices: [FitnetBLEService]
    var serviceMap = Dictionary<CBUUID, FitnetBLEService>();
    var charServMap = Dictionary<CBUUID, FitnetBLEService>();
    var readDelays: [Double] = Array(repeating: 0, count: READ_AVG_KEEPS)
    
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
        readDelays[readAvgPtr] = delay
        readAvgPtr = (readAvgPtr + 1) % Self.READ_AVG_KEEPS
        let hasValue = readDelays.count(where: { x in x != 0})
        avgReadDelay = readDelays.reduce(0, { a,b in
            if a == 0 {
                return b
            } else if b == 0 {
                return a
            } else {
                return a + b
            }
        })
        if hasValue != 0 {
            avgReadDelay /= Double(hasValue)
        }
    }
    
}

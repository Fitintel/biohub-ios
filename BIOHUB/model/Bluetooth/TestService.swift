//
//  TestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth
import SwiftUI
import Observation

@Observable
class TestService: FitnetPeripheralService, PTestService {
    static let TAG = "TestService"
    
    static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0xFB, 0x34, 0x9B,
                                                         0x5F, 0x80, 0x00,
                                                         0x00, 0x80, 0x00,
                                                         0x10, 0x00, 0x00,
                                                         0xFF, 0xFF, 0x00,
                                                         0x00].reversed())))
    static let LED_CONTROL_UUID = CBUUID(data: Data([UInt8]([0x12, 0x35])))

    private var foundService = false
    private var chars: Dictionary<CBUUID, CBCharacteristic> = Dictionary()
    var peripheral: CBPeripheral
 
    var isLoaded = false

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    func loadService(_ service: CBService) -> Bool {
        return Self.loadService(tag: Self.TAG,
                                service: service,
                                uuid: Self.SERVICE_UUID,
                                setFound: { foundService = true })
    }
    
    func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        return Self.loadCharacteristic(tag: Self.TAG,
                                       checkedChar: char,
                                       foundService: foundService,
                                       chars: [Self.LED_CONTROL_UUID],
                                       setFound: { cb in chars.updateValue(cb, forKey: cb.uuid) })
    }
    
    func writeLEDValue(value: Bool) {
        if (chars[Self.LED_CONTROL_UUID] == nil) {
            log.error("[\(Self.TAG)] Has not found LED Control UUID")
            return
        }
        
        peripheral.writeValue(Data([UInt8]([value ? 1 : 0])),
                              for: chars[Self.LED_CONTROL_UUID]!,
                              type: .withResponse)
    }
    
}

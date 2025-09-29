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
public class TestService: FitnetPeripheralService, PTestService {
    static let TAG = "TestService"
    
    public var ledValue: Bool? = nil
    public var deviceName: String? = "TODO: IMPLEMENT ME" // TODO: this

    static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0xFB, 0x34, 0x9B,
                                                         0x5F, 0x80, 0x00,
                                                         0x00, 0x80, 0x00,
                                                         0x10, 0x00, 0x00,
                                                         0xFF, 0xFF, 0x00,
                                                         0x00].reversed())))
    static let LED_CONTROL_UUID = CBUUID(data: Data([UInt8]([0x12, 0x35])))
    static let LED_READ_UUID = CBUUID(data: Data([UInt8]([0x12, 0x45])))

    private var foundService = false
    private var chars: Dictionary<CBUUID, CBCharacteristic> = Dictionary()
    var peripheral: CBPeripheral
 
    var isLoaded = false

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    public func loadService(_ service: CBService) -> Bool {
        return Self.loadService(tag: Self.TAG,
                                service: service,
                                uuid: Self.SERVICE_UUID,
                                setFound: {
            foundService = true
            
            // Read LED state right away
            self.readLEDState()
        })
    }
    
    // Reads the LED value
    func readLEDState() {
        if !chars.keys.contains(Self.LED_READ_UUID) {
            log.error("[\(Self.TAG)] Has not found LED Read UUID")
            return
        }
        // Request reading the value
        self.peripheral.readValue(for: chars[Self.LED_READ_UUID]!)
    }

    public func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        return Self.loadCharacteristic(tag: Self.TAG,
                                       checkedChar: char,
                                       foundService: foundService,
                                       chars: [Self.LED_CONTROL_UUID, Self.LED_READ_UUID],
                                       setFound: { cb in chars.updateValue(cb, forKey: cb.uuid) })
    }
    
    public func writeLEDValue(value: Bool) {
        if (chars[Self.LED_CONTROL_UUID] == nil) {
            log.error("[\(Self.TAG)] Has not found LED Control UUID")
            return
        }
        
        peripheral.writeValue(Data([UInt8]([value ? 1 : 0])),
                              for: chars[Self.LED_CONTROL_UUID]!,
                              type: .withResponse)
    }
    
    public func notifyRead(_ char: CBCharacteristic) -> Bool {
        if char.uuid == Self.LED_READ_UUID {
            if char.value == nil {
                self.ledValue = nil
            } else {
                self.ledValue = String(data: char.value!, encoding: .ascii) == "on"
            }
            return true
        }
        return false
    }

}

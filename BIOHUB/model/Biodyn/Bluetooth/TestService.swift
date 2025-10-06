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
public class TestService: FitnetBLEService, PTestService {
    private static let SERVICE_UUID: CBUUID = CBUUID(data: Data([UInt8]([0xFB, 0x34, 0x9B,
                                                         0x5F, 0x80, 0x00,
                                                         0x00, 0x80, 0x00,
                                                         0x10, 0x00, 0x00,
                                                         0xFF, 0xFF, 0x00,
                                                         0x00].reversed())))
    private var ledControlChar: LEDControlChar
    
    public var ledValue: Bool? { get { ledControlChar.ledValue } }

    init(_ peripheral: CBPeripheral) {
        let led = LEDControlChar(peripheral)
        self.ledControlChar = led

        super.init(peripheral,
                   name: "Test Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [led])
    }

    // Writes the LED value
    public func writeLEDValue(value: Bool) {
        ledControlChar.writeValue(data: Data([UInt8]([value ? 1 : 0])),
                                  type: .withResponse)
    }
    
    // Reads LED value
    public func readLEDValue() {
        ledControlChar.readValue()
    }

    @Observable
    private class LEDControlChar : FitnetBLEChar {
        public var ledValue: Bool?
        
        init(_ peripheral: CBPeripheral) {
            super.init(peripheral,
                       "LED Control",
                       CBUUID(data: Data([UInt8]([0x12, 0x35]))))
        }
        
        override func onRead(_ data: Data) {
            ledValue = data.first! > 0
        }
    }
}

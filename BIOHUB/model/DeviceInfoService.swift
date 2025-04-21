//
//  FitnetDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//


import CoreBluetooth
import os.log

class DeviceInformationService: FitnetPeripheralService {
    static let TAG = "DeviceInformationService"
    
    static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0x18, 0x0A])))
    static let MANUF_NAME_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x29])))
    static let FIRM_REV_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x26])))
    static let NUM_CHARS = 2
    
    private var foundService = false
    private var chars: Dictionary<CBUUID, CBCharacteristic> = Dictionary()
    var peripheral: CBPeripheral
 
    @Published var isLoaded = false
    @Published var manufNameStr: String?
    @Published var firmwareRevStr: String?
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    // Saves service info
    func loadService(_ service: CBService) -> Bool {
        if service.uuid == DeviceInformationService.SERVICE_UUID {
            log.info("[\(Self.TAG)] Found service UUID")
            foundService = true
            return true
        }
        return false
    }
    
    // Saves characteristic info
    func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        // Check if service found
        if !foundService {
            log.error("[\(Self.TAG)] Has not found service UUID yet.")
            return false
        }
        
        var found = false
        
        // Check for characteristics
        if char.uuid == Self.MANUF_NAME_STR_CHAR {
            log.info("[\(Self.TAG)] Found \"Manufacturer Name String\" Service")
            chars.updateValue(char, forKey: DeviceInformationService.MANUF_NAME_STR_CHAR)
            found = true
        } else if char.uuid == Self.FIRM_REV_STR_CHAR {
            log.info("[\(Self.TAG)] Found \"Firmware Revision String\" Service")
            chars.updateValue(char, forKey: DeviceInformationService.FIRM_REV_STR_CHAR)
            found = true
        }
        
        if chars.count == Self.NUM_CHARS {
            self.isLoaded = true
            log.info("[\(Self.TAG)] Loaded")
        }
        
        return found
    }
    
    // Called when a read is done
    func notifyRead(_ char: CBCharacteristic) -> Bool {
        if char.uuid == Self.MANUF_NAME_STR_CHAR {
            if char.value == nil {
                self.manufNameStr = nil
            } else {
                self.manufNameStr = String(data: char.value!, encoding: .ascii)
            }
            return true
        } else if char.uuid == Self.FIRM_REV_STR_CHAR {
            if char.value == nil {
                self.firmwareRevStr = nil
            } else {
                self.firmwareRevStr = String(data: char.value!, encoding: .ascii)
            }
            return true
        }
        return false
    }

    
    // Reads the manufacturer name string. manufNameStr will be updated when it is completed
    func readManufacturerNameString() {
        if !chars.keys.contains(Self.MANUF_NAME_STR_CHAR) {
            log.error("[\(Self.TAG)] Has not found Manufacturer Name String UUID")
            return
        }
        
        // Request reading the value
        self.peripheral.readValue(for: chars[Self.MANUF_NAME_STR_CHAR]!)
    }
    
    // Reads the firmware revision string. It will be updated when it is read
    func readFirmwareRevString() {
        if !chars.keys.contains(Self.FIRM_REV_STR_CHAR) {
            log.error("[\(Self.TAG)] Has not found the Firmware Revision String UUID")
            return
        }
        
        // Request reading the value
        self.peripheral.readValue(for: chars[Self.FIRM_REV_STR_CHAR]!)
    }
    
}

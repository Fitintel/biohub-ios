//
//  FitnetDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//


import CoreBluetooth
import os.log
import Observation

@Observable
public class DeviceInformationService: FitnetPeripheralService, PDeviceInfoService {
    static let TAG = "DeviceInformationService"
    
    static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0x18, 0x0A])))
    static let MANUF_NAME_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x29])))
    static let FIRM_REV_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x26])))
    static let NUM_CHARS = 2
    
    private var foundService = false
    private var chars: Dictionary<CBUUID, CBCharacteristic> = Dictionary()
    var peripheral: CBPeripheral
    
    var isLoaded = false
    public var manufNameStr: String?
    public var firmwareRevStr: String?
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    // Saves service info
    public func loadService(_ service: CBService) -> Bool {
        return Self.loadService(tag: Self.TAG, service: service,
                                uuid: Self.SERVICE_UUID,
                                setFound: {
            foundService = true
            
            // Read firmware revision and manuf name when created
            self.readFirmwareRevString()
            self.readManufacturerNameString()
        })
    }
    
    // Saves characteristic info
    public func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        return Self.loadCharacteristic(tag: Self.TAG,
                                       checkedChar: char,
                                       foundService: foundService,
                                       chars: [Self.MANUF_NAME_STR_CHAR, Self.FIRM_REV_STR_CHAR],
                                       setFound: { cb in chars.updateValue(cb, forKey: cb.uuid) })
    }
    
    // Called when a read is done
    public func notifyRead(_ char: CBCharacteristic) -> Bool {
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

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
public class DeviceInformationService: FitnetBLEService, PDeviceInfoService {
    private static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0x18, 0x0A])))
    private static let MANUF_NAME_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x29])))
    private static let MODEL_NUM_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x24])))
    private static let SERIAL_NUM_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x25])))
    private static let HARDWARE_REV_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x27])))
    private static let FIRMWARE_REV_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x26])))
    private static let SYSTEM_ID_STR_CHAR = CBUUID(data: Data([UInt8]([0x2A, 0x23])))
    
    public var manufNameStr: String? { get { return manufNameStrChar.value } }
    public var modelNumStr: String? { get { return  modelNumStrChar.value } }
    public var serialNumStr: String? { get { return serialNumStrChar.value } }
    public var harwareRevStr: String? { get  { return harwareRevStrChar.value } }
    public var firmwareRevStr: String? { get { return firmwareRevStrChar.value } }
    public var systemIdStr: String? { get { return systemIdStrChar.value } }
    
    public var manufNameStrChar: FitnetStringChar
    public var modelNumStrChar: FitnetStringChar
    public var serialNumStrChar: FitnetStringChar
    public var harwareRevStrChar: FitnetStringChar
    public var firmwareRevStrChar: FitnetStringChar
    public var systemIdStrChar: FitnetStringChar

    init(_ peripheral: CBPeripheral) {
        let manuf = FitnetStringChar(peripheral, "Manufacturer Name", Self.MANUF_NAME_STR_CHAR)
        self.manufNameStrChar = manuf
        
        let model = FitnetStringChar(peripheral, "Model Number", Self.MODEL_NUM_STR_CHAR)
        self.modelNumStrChar = model
        
        let serial = FitnetStringChar(peripheral, "Serial Number", Self.SERIAL_NUM_STR_CHAR)
        self.serialNumStrChar = serial
        
        let hardware = FitnetStringChar(peripheral, "Hardware Revision", Self.HARDWARE_REV_STR_CHAR)
        self.harwareRevStrChar = hardware
        
        let firmware = FitnetStringChar(peripheral, "Firmware Revision", Self.FIRMWARE_REV_STR_CHAR)
        self.firmwareRevStrChar = firmware
        
        let sys = FitnetStringChar(peripheral, "System ID", Self.SYSTEM_ID_STR_CHAR)
        self.systemIdStrChar = sys
        
        super.init(peripheral,
                   name: "Device Information Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [manuf, model, serial, hardware, firmware, sys])
    }
}

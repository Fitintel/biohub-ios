//
//  BluetoothPeripheralDelegate.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-20.
//


import CoreBluetooth
import OSLog
import SwiftUI

class BluetoothPeripheralDelegate: NSObject, ObservableObject, CBPeripheralDelegate {
    static let TAG = "BluetoothPeripheralDelegate"
    
    private let peripheral: CBPeripheral
    private let fitnetServices: FitnetServices
    
    init(peripheral: CBPeripheral, fitnetServices: FitnetServices) {
        self.peripheral = peripheral
        self.fitnetServices = fitnetServices
    }
    
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Called when services have been discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        log.debug("[\(Self.TAG)] Discovered services \(services)")
        discoverCharacteristics(peripheral: peripheral)
        
        for service in services {
            let _ = fitnetServices.loadService(service)
        }
    }
    
    
    // Called when characteristics have been discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        log.debug("[\(Self.TAG)] Discovered characteristics \(characteristics)")
        
        for char in characteristics {
            let _ = fitnetServices.loadCharacteristic(char)
        }
    }
    
    // Called when a characteristic has been read
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let _ = fitnetServices.notifyRead(characteristic)
    }
    
}

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
    static let TAG = "Bluetooth Peripheral Delegate"
    
    private let peripheral: CBPeripheral
    private let biodyn: Biodyn
    
    init(peripheral: CBPeripheral, fitnetServices: Biodyn) {
        self.peripheral = peripheral
        self.biodyn = fitnetServices
    }
    
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else { return }
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
            biodyn.loadService(service)
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
            biodyn.loadCharacteristic(service, char)
        }
    }
    
    // Called when a characteristic has been read
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        biodyn.notifyRead(characteristic)
    }
    
}

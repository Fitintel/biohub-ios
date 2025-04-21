//
//  BluetoothManager.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    static let TAG = "BluetoothManager"
    
    // Shared instance
    static let shared = BluetoothManager()
    
    // Core Bluetooth Central Manager
    private var centralManager: CBCentralManager!
    // Connected peripherals
    private var connectedPeripherals = Dictionary<CBPeripheral, FitnetServices>()
    private var peripheralDelegates = Dictionary<CBPeripheral, BluetoothPeripheralDelegate>()
    
    // Whether the bluetooth is on or not
    @Published var isBluetoothOn = false
    
    // Whether services have been initialized or not
    @Published var isInitialized = false
    
    // Singleton
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Returns the first peripheral's services
    func getFirstPeripheralServices() -> FitnetServices? {
        return self.connectedPeripherals.first?.value
    }
    
    // Called when bluetooth state is updated (ie. on, off, unsupported)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.scanServices()
            self.isBluetoothOn = true
            break
        case .poweredOff:
            // TODO: Prompt user to turn on Bluetooth
            self.isBluetoothOn = false
            log.info("[\(Self.TAG)] Bluetooth is off!")
            break
        case .resetting:
            self.isBluetoothOn = false
            log.info("[\(Self.TAG)] Bluetooth resetting, waiting for next state...")
            break
        case .unauthorized:
            // TODO: Prompt user to enable Bluetooth in settings
            self.isBluetoothOn = false
            log.warning("[\(Self.TAG)] Bluetooth is unauthorized!")
            break
        case .unsupported:
            // TODO: Alert user that their device does not support Bluetooth
            self.isBluetoothOn = false
            log.error("[\(Self.TAG)] Bluetooth is unsupported!")
            break
        case .unknown:
            log.warning("[\(Self.TAG)] Bluetooth state unknown, waiting for next state...")
            break
        @unknown default:
            // Wait for next state update
            log.warning("[\(Self.TAG)] Bluetooth state unknown, waiting for next state...")
            break
        }
    }
    
    // Scans for FITNET servies
    private func scanServices() {
        log.debug("[\(Self.TAG)] Scanning for FITNET devices...")
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    // Checks if the provided peripheral is a FITNET peripheral based on the manufacturer data
    func isFitnetPeripheral(peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
        if (advertisementData.contains(where: {
            (k, v) -> Bool in
            k == CBAdvertisementDataManufacturerDataKey
        })) {
            let manufData = advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData
            let bytes: [UInt8] = [0xF1, 0x72, 0xE7, 0x00]
            if manufData.isEqual(to: Data(bytes)) {
                return true
            }
        }
        return false
    }
    
    // Callback when advertisement packet from peripheral is recieved
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (isFitnetPeripheral(peripheral: peripheral, advertisementData: advertisementData)) {
            log.info("[\(Self.TAG)] Found FITNET Peripheral")
            centralManager.connect(peripheral)
            self.connectedPeripherals.updateValue(FitnetServices(peripheral), forKey: peripheral)
        }
    }
    
    // Callback when peripheral is connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        log.debug("[\(Self.TAG)] Connected to peripheral!")
        peripheralDelegates.updateValue(BluetoothPeripheralDelegate(peripheral: peripheral, fitnetServices: self.connectedPeripherals[peripheral]!),
                                        forKey: peripheral)
        
        peripheral.delegate = self.peripheralDelegates[peripheral]!
        peripheral.discoverServices(nil)
        
        self.isInitialized = true
    }
    
}

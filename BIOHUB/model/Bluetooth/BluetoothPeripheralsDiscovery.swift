//
//  BluetoothManager.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth
import SwiftUI
import Observation

@Observable
class BluetoothPeripheralsDiscovery: NSObject, ObservableObject, CBCentralManagerDelegate, PeripheralsDiscovery {
    typealias Peripheral = Biodyn
    typealias Listener = PeripheralsDiscoveryListener<Biodyn>

    static let TAG = "BluetoothDiscovery"
    
    // Shared instance
    static let shared = BluetoothPeripheralsDiscovery()
    
    // Core Bluetooth Central Manager
    private var centralManager: CBCentralManager!
    // Connected peripherals
    private var connectedPeripherals = Dictionary<CBPeripheral, Biodyn>()
    private var peripheralDelegates = Dictionary<CBPeripheral, BluetoothPeripheralDelegate>()
    
    var isDiscoverySupported: Bool {
        get {
            return isBluetoothOn && isBluetoothSupported
        }
    }
    
    var isBluetoothOn = false // Whether the bluetooth is on or not
    var isBluetoothSupported = true // Whether the device supports bluetooth
    var isInitialized = false // Whether services have been initialized or not
    
    var biodynListeners: [any Listener] = []
    
    // Singleton
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func addListener(_ l: any Listener) {
        self.biodynListeners.append(l)
    }

    private func notifyAdded(b: Biodyn) {
        biodynListeners.forEach { l in l.onConnected(b) }
    }
    
    private func notifyRemoved(b: Biodyn) {
        biodynListeners.forEach { l in l.onDisconnected(b) }
    }
    
    func getDiscoveryError() -> String {
        if !isBluetoothSupported {
            return "Bluetooth is not supported for your device."
        }
        if !isBluetoothOn {
            return "Bluetooth is not on. Enable it in settings."
        }
        return ""
    }
    
    // Called when bluetooth state is updated (ie. on, off, unsupported)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.scanServices()
            self.isBluetoothOn = true
            break
        case .poweredOff:
            self.isBluetoothOn = false
            log.info("[\(Self.TAG)] Bluetooth is off!")
            break
        case .resetting:
            self.isBluetoothOn = false
            log.info("[\(Self.TAG)] Bluetooth resetting, waiting for next state...")
            break
        case .unauthorized:
            self.isBluetoothOn = false
            log.warning("[\(Self.TAG)] Bluetooth is unauthorized!")
            break
        case .unsupported:
            self.isBluetoothSupported = false
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
    
    // Checks if the provided peripheral is a BIODYN-100 peripheral based on the manufacturer data
    private func isBiodyn(peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
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
        
        // Check if this peripheral is a BIODYN-100
        if (isBiodyn(peripheral: peripheral, advertisementData: advertisementData)) {
            log.info("[\(Self.TAG)] Found BIODYN-100")
            centralManager.connect(peripheral) // Connect
            let biodyn = Biodyn(peripheral) // Construct
            self.connectedPeripherals.updateValue(biodyn, forKey: peripheral) // Map & store locally
            self.notifyAdded(b: biodyn) // Notify listeners
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
    
    // Callback when peripheral is disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        log.debug("[\(Self.TAG)] Disconnected from peripheral.")
        guard let biodyn = self.connectedPeripherals.removeValue(forKey: peripheral) else { return }
        self.peripheralDelegates.removeValue(forKey: peripheral)
        self.notifyRemoved(b: biodyn)
    }
    
}

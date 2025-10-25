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
public final class BluetoothPeripheralsDiscovery: NSObject, ObservableObject, CBCentralManagerDelegate, PeripheralsDiscovery {
    public typealias Peripheral = Biodyn
    public typealias Listener = PeripheralsDiscoveryListener<Biodyn>

    static let TAG = "Bluetooth Discovery"
    
    // Shared instance
    static let shared = BluetoothPeripheralsDiscovery()
    
    // Core Bluetooth Central Manager
    private var centralManager: CBCentralManager!
    // Connected peripherals
    private var uuidPeripherals = Dictionary<UUID, CBPeripheral>()
    private var connectedPeripherals = Dictionary<UUID, Biodyn>()
    private var peripheralDelegates = Dictionary<UUID, BluetoothPeripheralDelegate>()
    
    public var isDiscoverySupported: Bool {
        get {
            return isBluetoothOn && isBluetoothSupported
        }
    }
    public var isBluetoothOn = false // Whether the bluetooth is on or not
    public var isBluetoothSupported = true // Whether the device supports bluetooth
    public var isInitialized = false // Whether services have been initialized or not
    public var isDiscovering: Bool = false

    private var biodynListeners: [any Listener] = []
    
    // Singleton
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func stopDiscovery() {
        isDiscovering = false
        log.debug("[\(Self.TAG)] Stopped scanning for FITNET devices")
        centralManager.stopScan()
    }
    
    public func startDiscovery() {
        isDiscovering = true
        log.debug("[\(Self.TAG)] Scanning for FITNET devices...")
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    public func getDiscoveryError() -> String {
        if !isBluetoothSupported {
            return "Bluetooth is not supported for your device."
        }
        if !isBluetoothOn {
            return "Bluetooth is not on. Enable it in settings to connect to FITNET devices."
        }
        return ""
    }
    
    public func disconnect(_ p: Biodyn) {
        var key: UUID?
        self.connectedPeripherals.forEach({
            uuid, biodyn in
            if biodyn.uuid == uuid {
                key = uuid
            }
        })
        if key != nil {
            self.centralManager.cancelPeripheralConnection(self.uuidPeripherals[key!]!)
            // Remove immediately
            self.connectedPeripherals.removeValue(forKey: key!)
            self.peripheralDelegates.removeValue(forKey: key!)
            self.notifyRemoved(b: p)
        }
    }
    
    // Called when bluetooth state is updated (ie. on, off, unsupported)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.isBluetoothOn = true
            self.startDiscovery()
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
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Check if this peripheral is a BIODYN-100
        if (isBiodyn(peripheral: peripheral, advertisementData: advertisementData)) {
            log.info("[\(Self.TAG)] Found BIODYN-100")
            centralManager.connect(peripheral) // Connect
            let biodyn = Biodyn(peripheral) // Construct
            self.connectedPeripherals.updateValue(biodyn, forKey: peripheral.identifier) // Map & store locally

            self.notifyAdded(b: biodyn) // Notify listeners
        }
    }
    
    // Callback when peripheral is connected
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        log.debug("[\(Self.TAG)] Connected to peripheral!")
        uuidPeripherals.updateValue(peripheral, forKey: peripheral.identifier)
        peripheralDelegates.updateValue(BluetoothPeripheralDelegate(peripheral: peripheral, fitnetServices: self.connectedPeripherals[peripheral.identifier]!),
                                        forKey: peripheral.identifier)
        
        peripheral.delegate = self.peripheralDelegates[peripheral.identifier]!
        peripheral.discoverServices(nil)
        
        self.isInitialized = true
    }
    
    // Callback when peripheral is disconnected
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        log.debug("[\(Self.TAG)] Disconnected from peripheral.")
        
        var toRemove = [peripheral.identifier]
        self.uuidPeripherals.forEach({ k,v in
            if v.state != .connected {
                toRemove.append(k)
            }
        })
        toRemove.forEach({ uuid in
            self.removeByUUID(uuid)
        })
    }
    

    private func removeByUUID(_ uuid: UUID) {
        guard let biodyn = self.connectedPeripherals.removeValue(forKey: uuid) else { return }
        self.peripheralDelegates.removeValue(forKey: uuid)
        self.uuidPeripherals.removeValue(forKey: uuid)
        self.notifyRemoved(b: biodyn)
    }
    
    public func addListener(_ l: any Listener) {
        self.biodynListeners.append(l)
    }

    private func notifyAdded(b: Biodyn) {
        biodynListeners.forEach { l in l.onConnected(b) }
    }
    
    private func notifyRemoved(b: Biodyn) {
        biodynListeners.forEach { l in l.onDisconnected(b) }
    }

}

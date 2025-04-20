//
//  ContentView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-03.
//

import SwiftUI
import CoreBluetooth
import OSLog

let log = Logger()

struct ContentView: View {
    var body: some View {
        BluetoothViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct BluetoothViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BluetoothViewController {
        return BluetoothViewController()
    }
    
    func updateUIViewController(_ uiViewController: BluetoothViewController, context: Context) {
        // View controller was updated!
    }
}

class BluetoothViewController: UIViewController, CBCentralManagerDelegate {
    
    // Core Bluetooth Central Manager
    private var centralManager: CBCentralManager!
    
    // Connected peripheral
    private var connectedPeripheral: CBPeripheral? = nil
    
    // Peripheral delegate
    private var peripheralDelegate: FitnetPeripheralDelegate? = nil
    
    // Called when bluetooth state is updated (ie. on, off, unsupported)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scanServices()
            break
        case .poweredOff:
            // TODO: Prompt user to turn on Bluetooth
            log.info("[BluetoothViewController] Bluetooth is off!")
            break
        case .resetting:
            log.info("[BluetoothViewController] Bluetooth resetting, waiting for next state...")
            break
        case .unauthorized:
            // TODO: Prompt user to enable Bluetooth in settings
            log.warning("[BluetoothViewController] Bluetooth is unauthorized!")
            break
        case .unsupported:
            // TODO: Alert user that their device does not support Bluetooth
            log.error("[BluetoothViewController] Bluetooth is unsupported!")
            break
        case .unknown:
            log.warning("[BluetoothViewController] Bluetooth state unknown, waiting for next state...")
            break
        @unknown default:
            // Wait for next state update
            log.warning("[BluetoothViewController] Bluetooth state unknown, waiting for next state...")
            break
        }
    }
    
    // Scans for FITNET servies
    func scanServices() {
        // TODO: Implement me
        log.debug("[BluetoothViewController] Scanning for FITNET devices...")
        centralManager.scanForPeripherals(withServices: nil)
    }
    
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
            log.info("[BluetoothViewController] Found FITNET Peripheral")
            centralManager.connect(peripheral)
            self.connectedPeripheral = peripheral
        }
    }
    
    // Callback when peripheral is connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        log.debug("[BluetoothViewController] Connected to peripheral!")
        self.peripheralDelegate = FitnetPeripheralDelegate()
        peripheral.delegate = self.peripheralDelegate!
        peripheral.discoverServices(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Right now we have no custom queue and the delegate is this class
        // TODO: Create separate queue for Bluetooth activity
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        log.debug("[BluetoothViewController] View did in fact finish loading")
    }
}

#Preview {
    ContentView()
}

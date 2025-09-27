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

struct MainView: View {
    
    @State var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        VStack {
            if bluetoothManager.isInitialized {
                BluetoothOnView()
            } else if bluetoothManager.isBluetoothOn {
                ScanningView()
            } else if !bluetoothManager.isBluetoothSupported {
                Text("Your device does not support Bluetooth.").multilineTextAlignment(.center)
            } else {
                Text("Bluetooth is turned off. Please enable it in settings.").multilineTextAlignment(.center)
            }
        }
    }
}

struct ScanningView: View {
    var body: some View {
        VStack {
            Text("Scanning for FITNET devices")
            ProgressView()
        }
    }
}

struct BluetoothOnView: View {
    
    @State var bluetoothManager = BluetoothManager.shared

    var body: some View {
        VStack {
            Text("Connected Devices:")
            List(bluetoothManager.peripherals, id: \.uuid.uuidString) { item in
                HStack {
                    Text(item.deviceInfoService.manufNameStr ?? "...")
                    Text(item.deviceInfoService.firmwareRevStr ?? "...")
                }
            }
        }
    }
}

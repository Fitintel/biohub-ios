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

struct TestView: View {
    
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        VStack {
            if bluetoothManager.isInitialized {
                BluetoothOnView(deviceInfo: bluetoothManager.getFirstPeripheralServices()!.deviceInfoService)
            } else {
                Text("Bluetooth Not Turned On")
            }
        }
    }
}

struct BluetoothOnView: View {
    
    @ObservedObject var deviceInfo: DeviceInformationService
    
    var body: some View {
        VStack {
            Button(action: {
                deviceInfo.readManufacturerNameString()
            }, label: {
                Text("Read Manufacturer Name")
            })
            Text(deviceInfo.manufNameStr ?? "nil")
            
            Button(action: {
                deviceInfo.readFirmwareRevString()
            }, label: {
                Text("Read Firmware Revision String")
            })
            Text(deviceInfo.firmwareRevStr ?? "nil")
        }
    }
}

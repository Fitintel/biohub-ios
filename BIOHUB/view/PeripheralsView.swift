//
//  PeripheralsView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//


import SwiftUI
import CoreBluetooth
import OSLog

struct PeripheralsView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {

    @Bindable var peripheralsManager: PeripheralsManager<B, BD>
    
    var body: some View {
        VStack {
            Text("Connected Devices:")
            List(self.peripheralsManager.biodyns, id: \.uuid.uuidString) { item in
                HStack {
                    Text(item.deviceInfoService.manufNameStr ?? "...")
                    Text(item.deviceInfoService.firmwareRevStr ?? "...")
                }
            }
        }
    }
}

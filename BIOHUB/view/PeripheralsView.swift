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
    
    @Binding var fitnet: Fitnet<B, BD>?
    @Bindable var peripheralsManager: PeripheralsManager<B, BD>
    @State private var selectedDevices: Set<UUID> = []
    
    var body: some View {
        VStack {
            Button(action: {
                self.peripheralsManager.biodynDiscovery.stopDiscovery()
                self.peripheralsManager.keepConnected(selectedDevices)
                fitnet = Fitnet(self.peripheralsManager)
            }) {
                Text(selectedDevices.count == 0 ? "Select Devices for Net" : "Create Net")
            }.padding(.top, 2).disabled(selectedDevices.count == 0)
            List(self.peripheralsManager.biodyns, id: \.uuid.uuidString) { item in
                Button(action: {
                    if selectedDevices.contains(item.uuid) {
                        selectedDevices.remove(item.uuid)
                    } else {
                        selectedDevices.insert(item.uuid)
                    }
                }) {
                    HStack {
                        Text("BIODYN-100 v\(item.deviceInfoService.firmwareRevStr ?? "?") by \(item.deviceInfoService.manufNameStr ?? "???")")
                        if selectedDevices.contains(where: { x in x == item.uuid}) {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

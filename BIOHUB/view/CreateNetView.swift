//
//  PeripheralsView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//


import SwiftUI
import CoreBluetooth
import OSLog

struct CreateNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @State private var selectedDevices: Set<UUID> = []
    
    var body: some View {
        VStack {
            if !app.fitnet.biodynDiscovery.isDiscoverySupported {
                Text(app.fitnet.biodynDiscovery.getDiscoveryError()).multilineTextAlignment(.center)
            } else if !app.fitnet.hasBiodyns {
                Text("Scanning for FITNET devices")
                ProgressView()
            } else {
                Divider()
                HStack {
                    Button(action: {
                        app.fitnet.biodynDiscovery.stopDiscovery()
                        app.fitnet.keepConnected(selectedDevices)
                        selectedDevices = []
                        app.net.path.append(NetViewRoute.configure)
                    }) {
                        Text(selectedDevices.count == 0 ? "Select Devices for Net" : "Create Net")
                    }.disabled(selectedDevices.count == 0)
                    Spacer()
                }.padding(.horizontal)
                Divider()
                List {
                    ForEach(app.fitnet.biodyns, id: \.uuid.uuidString) { item in
                        Button(action: {
                            if selectedDevices.contains(item.uuid) {
                                selectedDevices.remove(item.uuid)
                            } else {
                                selectedDevices.insert(item.uuid)
                            }
                        }) {
                            HStack {
                                Text("BIODYN \(item.deviceInfoService.systemIdStr ?? "???") \(item.deviceInfoService.firmwareRevStr ?? "???")")
                                if selectedDevices.contains(where: { x in x == item.uuid}) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    if app.fitnet.biodynDiscovery.isDiscovering {
                        HStack {
                            Spacer()
                            ProgressView().padding(.vertical, 12)
                            Spacer()
                        }.listRowSeparator(.hidden)
                    }
                }.listStyle(.plain)
            }
        }
    }
}

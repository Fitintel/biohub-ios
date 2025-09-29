//
//  NetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import SwiftUI

struct ConfigureNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @State private var netMode = NetMode.selfTest
    @State private var confirmRecreateNet = false
    @State private var netModeStarted = false
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Text("Net Mode: ")
                Picker("Net Mode", selection: $netMode) {
                    Text("Self Test").tag(NetMode.selfTest)
                    Text("Data Collection").tag(NetMode.dataCollection)
                }
                Spacer()
            }.padding(.horizontal)
            HStack {
                Button(action: {
                    switch netMode {
                    case .selfTest:
                        app.net.path.append(NetViewRoute.selfTest)
                        break
                    case .dataCollection:
                        app.net.path.append(NetViewRoute.dataCollection)
                        break
                    }
                }) {
                    Text("Start Net")
                }
                Spacer()
                Button(role: .destructive, action: {
                    confirmRecreateNet = true
                }) {
                    Text("Recreate Net")
                }
                .alert("Create a new net and lose this configuration?", isPresented: $confirmRecreateNet) {
                    Button("Delete", role: .destructive) {
                        app.fitnet.biodynDiscovery.startDiscovery()
                        let _ = app.net.path.popLast()
                    }
                    Button("Cancel", role: .cancel) { confirmRecreateNet = false }
                }
            }.padding(.bottom).padding(.horizontal)
            Divider()
            Text("Devices in Net").multilineTextAlignment(.center)
            List {
                ForEach(app.fitnet.biodyns, id: \.uuid.uuidString) { item in
                    Text("BIODYN \(item.testService.deviceName ?? "???") \(item.deviceInfoService.firmwareRevStr ?? "???")")
                }
            }.listStyle(.plain)
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Configure Net")
    }
}


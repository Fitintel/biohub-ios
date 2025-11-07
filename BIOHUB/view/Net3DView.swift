//
//  3DNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-28.
//

import SwiftUI
import Foundation

struct Net3DView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var net: Net3DMode<B, BD>
    
    public var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(role: .destructive, action: {
                        net.stopPolling()
                        let _ = app.net.path.popLast()
                    }) {
                        Text("Back")
                    }
                    Spacer()
                    Button(action: {
                        net.isPolling ? net.stopPolling() : net.startPolling()
                    }) {
                        Text(net.isPolling ? "Stop" : "Start")
                    }.disabled(net.isConfiguringDevices)
                    Spacer()
                    Button(action: {
                        net.resetPositions()
                    }) {
                        Text("Reset Position")
                    }
                }.padding()
                if net.isConfiguringDevices {
                    HStack {
                        Text("Configuring devices")
                        ProgressView()
                    }.padding(.horizontal)
                }
                List(Array(net.b3ds.values), id: \.biodyn.uuid.uuidString) { b3d in
                    VStack {
                        Text("Biodyn \(b3d.biodyn.deviceInfoService.systemIdStr ?? "?")")
                        BiodynView3D<B, BD>(biodyn: b3d)
                    }
                }
            }
        }
        .navigationTitle("3D View")
        .navigationBarBackButtonHidden()
    }
}

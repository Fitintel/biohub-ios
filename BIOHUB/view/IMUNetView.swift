//
//  IMUNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import SwiftUI

struct IMUNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var imuNet: IMUNetMode<B, BD>
    
    var body: some View {
        VStack {
            Button(action: {
                if imuNet.isPolling {
                    imuNet.stopPolling()
                } else {
                    imuNet.startPolling()
                }
            }) {
                Text(imuNet.isPolling ? "Stop Reading" : "Start Reading")
            }
            List (app.fitnet.biodyns, id: \.uuid.uuidString) { item in
                HStack {
                    Text("\(item.deviceInfoService.systemIdStr ?? "UNKNOWN") XYZ:")
                    Spacer()
                    Text("\(String(format: "%.2f", item.imuService.planarAccel?.x ?? 0))").monospaced()
                    Spacer()
                    Text("\(String(format: "%.2f", item.imuService.planarAccel?.y ?? 0))").monospaced()
                    Spacer()
                    Text("\(String(format: "%.2f", item.imuService.planarAccel?.z ?? 0))").monospaced()
                }
                .animation(nil, value: UUID())
            }
        }
        .navigationTitle("IMU Reading")
    }
    
}

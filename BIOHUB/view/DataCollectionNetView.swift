//
//  DataCollectionNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-29.
//

import SwiftUI

struct DataCollectionNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var dNet: DataCollectionNetMode<B, BD>
    @State private var isUploading: Bool = false
    @State private var isUploaded: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                Button(role: dNet.isPolling ? .destructive : nil , action: {
                    dNet.isPolling ? dNet.stopPolling() : dNet.startPolling()
                }) {
                    Text(dNet.isPolling ? "Stop Data Collection" : "Start Data Collection")
                }
                HStack {
                    Button(action: {
                        dNet.reset()
                        isUploaded = false
                    }) {
                        Text("Clear Data")
                    }.disabled(isUploading)
                    Spacer()
                    Button(action: {
                        isUploading = true
                        Task {
                            do {
                                try await app.fitnetUser!.uploadAllData(dNet.collectedData())
                                isUploading = false
                                isUploaded = true
                            } catch {
                                log.error("[IMUNetView] Failed to upload IMU data: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text(isUploaded ? "Data Uploaded" : (app.isLoggedIn ? "Save Session" : "Log In to Save"))
                    }
                    .disabled(!app.isLoggedIn || dNet.isPolling || isUploading || isUploaded)
                }
            }.padding()
            List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                VStack {
                    DatedSIMD3LineChart(max: 30, data: dNet.dataFor(biodyn).imu.planar)
                    //                    DatedSIMD3LineChart(max: 30, data: dNet.dataFor(biodyn).imu.gyro)
                }
            }
        }
        .navigationTitle("Net Data Collection")
        .onDisappear {
            dNet.stopPolling()
            dNet.reset()
        }
    }
}

//
//  TrainingView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-11-27.
//

import SwiftUI

struct TrainingView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var dNet: DataCollectionNetMode<B, BD>
    @State private var isUploading: Bool = false
    @State private var isUploaded: Bool = false
    @State private var dataLabel: String = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        dNet.stopPolling()
                        dNet.reset()
                        let _ = app.net.path.popLast()
                    }) {
                        Text("Back")
                    }
                    Spacer()
                    Button(action: {
                        dNet.reset()
                        isUploaded = false
                    }) {
                        Text("Clear Data")
                    }
                    .disabled(isUploading || dNet.isConfiguringDevices)
                }
                .padding()
                HStack {
                    Button(action: {
                        dNet.isPolling ? dNet.stopPolling() : dNet.startPolling()
                    }) {
                        Text(dNet.isPolling ? "Stop Reading" : "Start Reading")
                    }.disabled(dNet.isConfiguringDevices || isUploading)
                    Spacer()
                    Button(action: {
                        isUploading = true
                        Task {
                            do {
                                try await app.fitnetUser!.uploadTrainingData(label: dataLabel, data: dNet.collectedData())
                                isUploading = false
                                isUploaded = true
                            } catch {
                                log.error("[IMUNetView] Failed to upload data: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text(isUploaded ? "Data Uploaded" : (app.isLoggedIn ? "Save Session" : "Log In to Save"))
                    }
                    .disabled(!app.isLoggedIn || dNet.isPolling || isUploading || isUploaded || dNet.isConfiguringDevices)
                    if (isUploading) {
                        ProgressView()
                    }
                }.padding(.horizontal)
                HStack {
                    VStack {
                        Text("Enter data label below:")
                        TextField("Data Label", text: $dataLabel)
                    }
                }.padding()
                if dNet.isConfiguringDevices {
                    HStack {
                        Text("Configuring devices")
                        ProgressView()
                    }.padding(.horizontal)
                }
                List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                    VStack {
                        HStack {
                            Text("\(biodyn.deviceInfoService.systemIdStr ?? "UNKNOWN")")
                        }
                    }
                }
            }
            .navigationTitle("Net Data Collection")
            .navigationBarBackButtonHidden()
            .onDisappear {
                dNet.stopPolling()
                dNet.reset()
            }
        }
    }
}

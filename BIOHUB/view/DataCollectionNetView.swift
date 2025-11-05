//
//  DataCollectionNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-29.
//

import SwiftUI

struct DataCollectionNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    private enum DataReadingType { case planar, gyro, mag, emg }
    
    @Bindable var app: AppState<B, BD>
    @Bindable var dNet: DataCollectionNetMode<B, BD>
    @State private var isUploading: Bool = false
    @State private var isUploaded: Bool = false
    @State private var imuGraph: DataReadingType = .planar
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        dNet.isPolling ? dNet.stopPolling() : dNet.startPolling()
                    }) {
                        Text(dNet.isPolling ? "Stop Reading" : "Start Reading")
                    }
                    .disabled(isUploading)
                    Spacer()
                    Picker("IMU Reading", selection: $imuGraph) {
                        Text("Planar Accel").tag(DataReadingType.planar)
                        Text("Gyro Accel").tag(DataReadingType.gyro)
                        Text("Magnetometer").tag(DataReadingType.mag)
                        Text("EMG").tag(DataReadingType.emg)
                    }
                }
                .padding()
                HStack {
                    Button(action: {
                        dNet.reset()
                        isUploaded = false
                    }) {
                        Text("Clear Data")
                    }
                    .disabled(isUploading)
                    Spacer()
                    Button(action: {
                        isUploading = true
                        Task {
                            do {
                                try await app.fitnetUser!.uploadAllData(dNet.collectedData())
                                isUploading = false
                                isUploaded = true
                            } catch {
                                log.error("[IMUNetView] Failed to upload data: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text(isUploaded ? "Data Uploaded" : (app.isLoggedIn ? "Save Session" : "Log In to Save"))
                    }
                    .disabled(!app.isLoggedIn || dNet.isPolling || isUploading || isUploaded)
                    if (isUploading) {
                        ProgressView()
                    }
                }
                .padding()
                HStack {
                    let takenAvgPct = Int((dNet.capacity.average ?? 0) * 100)
                    Text("Running at capacity: \(takenAvgPct)%")
                }.padding()
                List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                    VStack {
                        HStack {
                            Text("\(biodyn.deviceInfoService.systemIdStr ?? "UNKNOWN") XYZ:")
                        }
                        .animation(nil, value: UUID())
                        switch imuGraph {
                        case .planar: DatedSIMD3LineChart(max: dNet.maxPlanarAccel, data: dNet.dataFor(biodyn).imu.planar)
                        case .gyro: DatedSIMD3LineChart(max: dNet.maxGyroAccel, data: dNet.dataFor(biodyn).imu.gyro)
                        case .mag: DatedSIMD3LineChart(max: dNet.maxMagnetometer, data: dNet.dataFor(biodyn).imu.magneto)
                        case .emg: DatedFloatLineChart(max: dNet.maxEmg, data: dNet.dataFor(biodyn).emg.floats)
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

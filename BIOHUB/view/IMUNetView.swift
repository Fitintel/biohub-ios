//
//  IMUNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import SwiftUI
import Charts

struct IMUNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    private enum IMUReadingType { case planar, gyro, mag }
    
    @EnvironmentObject var auth: AuthService
    @Bindable var app: AppState<B, BD>
    @Bindable var imuNet: IMUNetMode<B, BD>
    @State private var imuGraph: IMUReadingType = .planar
    @State private var isUploading: Bool = false
    @State private var isUploaded: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        imuNet.isPolling ? imuNet.stopPolling() : imuNet.startPolling()
                    }) {
                        Text(imuNet.isPolling ? "Stop Reading" : "Start Reading")
                    }
                    .disabled(isUploading)
                    Spacer()
                    Picker("IMU Reading", selection: $imuGraph) {
                        Text("Planar Accel").tag(IMUReadingType.planar)
                        Text("Gyro Accel").tag(IMUReadingType.gyro)
                        Text("Magnetometer").tag(IMUReadingType.mag)
                    }
                }
                .padding()
                HStack {
                    Button(action: {
                        imuNet.reset()
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
                                try await app.fitnetUser!.uploadIMUData(imuNet.collectedData())
                                isUploading = false
                                isUploaded = true
                            } catch {
                                log.error("[IMUNetView] Failed to upload IMU data: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text(isUploaded ? "Data Uploaded" : "Save Session")
                    }
                    .disabled(!app.isLoggedIn || imuNet.isPolling || isUploading || isUploaded)
                    if (isUploading) {
                        ProgressView()
                    }
                }
                .padding()
                List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                    VStack {
                        HStack {
                            Text("\(biodyn.deviceInfoService.systemIdStr ?? "UNKNOWN") XYZ:")
                            Spacer()
                            switch imuGraph {
                            case .planar: SIMD3View(simd3: biodyn.imuService.planarAccel)
                            case .gyro: SIMD3View(simd3: biodyn.imuService.gyroAccel)
                            case .mag: SIMD3View(simd3: biodyn.imuService.magnetometer)
                            }
                        }
                        .animation(nil, value: UUID())
                        switch imuGraph {
                        case .planar: DatedSIMD3LineChart(max: imuNet.maxPlanarAccel, data: imuNet.dataFor(biodyn).planar)
                        case .gyro: DatedSIMD3LineChart(max: imuNet.maxGyroAccel, data: imuNet.dataFor(biodyn).gyro)
                        case .mag: DatedSIMD3LineChart(max: imuNet.maxMagnetometer, data: imuNet.dataFor(biodyn).magneto)
                        }
                    }
                }
            }
            .navigationTitle("IMU Reading")
            .onDisappear {
                imuNet.stopPolling()
                imuNet.reset()
            }
        }
        
    }
}

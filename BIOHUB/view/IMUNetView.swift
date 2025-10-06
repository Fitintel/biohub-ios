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
    
    @Bindable var app: AppState<B, BD>
    @Bindable var imuNet: IMUNetMode<B, BD>
    @State private var imuGraph: IMUReadingType = .planar
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        imuNet.isPolling ? imuNet.stopPolling() : imuNet.startPolling()
                    }) {
                        Text(imuNet.isPolling ? "Stop Reading" : "Start Reading")
                    }
                    Spacer()
                    Picker("IMU Reading", selection: $imuGraph) {
                        Text("Planar Accel").tag(IMUReadingType.planar)
                        Text("Gyro Accel").tag(IMUReadingType.gyro)
                        Text("Magnetometer").tag(IMUReadingType.mag)
                    }
                }
                HStack {
                    Button(action: {
                        imuNet.reset()
                    }) {
                        Text("Clear Data")
                    }
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

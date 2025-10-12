//
//  EMGNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import SwiftUI
import Charts

struct EMGNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @EnvironmentObject var auth: AuthService
    @Bindable var app: AppState<B, BD>
    @Bindable var emgNet: EMGNetMode<B, BD>
    @State private var isUploading: Bool = false
    @State private var isUploaded: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        emgNet.isPolling ? emgNet.stopPolling() : emgNet.startPolling()
                    }) {
                        Text(emgNet.isPolling ? "Stop Reading" : "Start Reading")
                    }
                    .disabled(isUploading)
                    Spacer()
                    Button(action: {
                        emgNet.reset()
                        isUploaded = false
                    }) {
                        Text("Clear Data")
                    }
                }
            }
            .padding()
            List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                VStack {
                    HStack {
                        Text("\(biodyn.deviceInfoService.systemIdStr ?? "UNKNOWN"):")
                        Spacer()
                        Text("\(biodyn.emgService.emg?.formatted() ?? "?")")
                    }
                    .animation(nil, value: UUID())
                    DatedFloatLineChart(max: emgNet.maxEMG, data: emgNet.dataFor(biodyn).floats)
                }
            }
        }
        .navigationTitle("EMG Reading")
        .onDisappear {
            emgNet.stopPolling()
            emgNet.reset()
        }
    }
}

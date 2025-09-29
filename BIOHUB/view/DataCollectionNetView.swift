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
    @Bindable var netMode: DataCollectionNetMode<B, BD>
    
    var body: some View {
        VStack {
            Button(role: netMode.collectingData ? .destructive : nil , action: {
                netMode.startDataCollection()
            }) {
                Text(netMode.collectingData ? "Stop Data Collection" : "Start Data Collection")
            }
            if netMode.collectingData {
                Text("Collecting data...")
                ProgressView()
            }
        }
        .navigationTitle("Net Data Collection")
    }
}

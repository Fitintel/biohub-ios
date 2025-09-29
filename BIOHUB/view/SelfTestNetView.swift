//
//  SelfTestNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import SwiftUI

struct SelfTestNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var netMode: SelfTestNetMode<B, BD>
    
    var body: some View {
        VStack {
            List (app.fitnet.biodyns, id: \.uuid.uuidString) { item in
                HStack {
                    Text("BIODYN \(item.testService.deviceName ?? "???") \(item.deviceInfoService.firmwareRevStr ?? "???")")
                    Spacer()
                    if item.selfTestService.selfTestOk == false {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                    } else if item.selfTestService.selfTestOk == true {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    } else {
                        ProgressView()
                    }
                }
            }.listStyle(.plain)
        }
        .navigationTitle("Net Self-Test")
    }
}

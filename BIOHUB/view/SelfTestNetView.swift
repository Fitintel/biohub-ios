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
                VStack {
                    HStack {
                        Text("BIODYN \(item.deviceInfoService.systemIdStr ?? "???") \(item.deviceInfoService.firmwareRevStr ?? "???")")
                        Spacer()
                        if item.selfTestService.selfTestState == SelfTestState.completedWithError {
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                        } else if item.selfTestService.selfTestState == SelfTestState.completedOk {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        } else if item.selfTestService.selfTestState == SelfTestState.running {
                            ProgressView()
                        } else if item.selfTestService.selfTestState == SelfTestState.notStarted {
                            Text("-")
                        } else if item.selfTestService.selfTestState == SelfTestState.cancelled {
                            Image(systemName: "xmark")
                                .foregroundStyle(.yellow)
                        }
                    }
                    if item.selfTestService.selfTestState == SelfTestState.completedWithError {
                        if item.selfTestService.selfTestError != nil {
                            HStack {
                                Text("--->")
                                Spacer()
                                Text(item.selfTestService.selfTestError!)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                }
            }.listStyle(.plain)
        }
        .navigationTitle("Net Self-Test")
    }
}

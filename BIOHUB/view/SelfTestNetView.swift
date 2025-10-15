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
                        switch item.selfTestService.selfTestState {
                        case .completedWithError:
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                        case .completedOk:
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        case .running:
                            ProgressView()
                        case .notStarted:
                            Text("-")
                        case .cancelled:
                            Image(systemName: "xmark")
                                .foregroundStyle(.yellow)
                        case .invalid:
                            Text("!").foregroundStyle(.red)
                        case .none:
                            Text("?")
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
                    if item.selfTestService.selfTestState == SelfTestState.invalid {
                        HStack {
                            Text("--->")
                            Spacer()
                            Text("Could not retrieve results")
                        }
                    }
                }
            }.listStyle(.plain)
        }
        .navigationTitle("Net Self-Test")
        .onAppear {
            netMode.start()
        }
        .onDisappear {
            netMode.close()
        }
    }
}

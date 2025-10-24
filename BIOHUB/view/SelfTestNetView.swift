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
                        Text("BIODYN \(item.deviceInfoService.systemIdStr ?? "?") \(item.deviceInfoService.firmwareRevStr ?? "?")")
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
                    HStack {
                        Text("-->").font(.system(size: 10))
                        let hard = item.deviceInfoService.harwareRevStr ?? ""
                        let manuf = item.deviceInfoService.manufNameStr ?? ""
                        let model = item.deviceInfoService.modelNumStr ?? ""
                        let serial = item.deviceInfoService.serialNumStr ?? ""
                        Text("Hardware \(hard) by \(manuf) [Model \(model), Serial \(serial)]").font(.system(size: 9))
                        Spacer()
                    }
                    HStack {
                        let readDelay = UInt32(item.avgReadDelay * 1000)
                        Text("-->").font(.system(size: 10))
                        Text("Avg read \(readDelay)ms").font(.system(size: 9))
                        Spacer()
                    }
                    HStack {
                        let ticker = item.dfService.ticker?.formatted() ?? "No heartbeat"
                        let tickerErr = item.dfService.tickerErrorMs?.formatted() ?? "Unknown "
                        Text("-->").font(.system(size: 10))
                        Text("Tick \(ticker) with error of \(tickerErr)ms").font(.system(size: 9))
                        Spacer()
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

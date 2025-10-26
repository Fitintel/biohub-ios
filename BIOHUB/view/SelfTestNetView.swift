//
//  SelfTestNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import SwiftUI

struct SelfTestNetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    private struct BiodynUIInfo {
        let avgReadDelay: Double?
        let avgWriteDelay: Double?
        let avgCommDelay: Double?
        let ticker: UInt64?
        let tickerErrorMs: Double?
    }
    
    @Bindable var app: AppState<B, BD>
    @Bindable var netMode: SelfTestNetMode<B, BD>
    @State private var uiUpdatesTask: Task<Void, Never>? = nil
    @State private var bi: [UUID: BiodynUIInfo] = [:]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    netMode.close()
                    stopUIUpdates()
                    let _ = app.net.path.popLast()
                }) {
                    Text("Back")
                }
                Spacer()
                Button(action: {
                    netMode.isPolling ? netMode.close() : netMode.start()
                }) {
                    Text(netMode.isPolling ? "Stop" : "Start")
                }
            }.padding()
            List (app.fitnet.biodyns, id: \.uuid.uuidString) { item in
                let bd = bi[item.uuid]
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
                        Text("-->").font(.system(size: 10))
                        Text("Avg read \(UInt32(bd?.avgReadDelay ?? 0))ms, Avg write \(UInt32(bd?.avgWriteDelay ?? 0))ms").font(.system(size: 9))
                        Spacer()
                    }
                    HStack {
                        let ticker = bd?.ticker?.formatted() ?? "No heartbeat"
                        let tickerErr = bd?.tickerErrorMs?.formatted() ?? "Unknown "
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
        .navigationBarBackButtonHidden()
        .onAppear {
            startUIUpdates()
            netMode.start()
        }
        .onDisappear {
            stopUIUpdates()
            netMode.close()
        }
    }
    
    private func startUIUpdates() {
        uiUpdatesTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                for b in app.fitnet.biodyns {
                    bi[b.uuid] = BiodynUIInfo(
                        avgReadDelay: b.avgReadDelay,
                        avgWriteDelay: b.avgWriteDelay,
                        avgCommDelay: b.avgCommDelay,
                        ticker: b.dfService.ticker,
                        tickerErrorMs: b.dfService.tickerErrorMs
                    )
                }
            }
        }
    }
    
    private func stopUIUpdates() {
        uiUpdatesTask?.cancel()
        uiUpdatesTask = nil
    }
}

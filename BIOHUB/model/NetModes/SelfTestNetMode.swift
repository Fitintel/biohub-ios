//
//  SelfTestNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
public class SelfTestNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = Fitnet<B, BDiscovery>
    
    public let fitnet: Fitnet<B, BDiscovery>
    private var readTask: Task<Void, Never>? = nil
    public var heartbeat: Heartbeat<B, BDiscovery>
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        self.heartbeat = Heartbeat(fitnet)
    }
    
    public func start() {
        self.readTask?.cancel()
        self.readTask = Task {
            for b in fitnet.biodyns {
                b.selfTestService.runSelfTest()
                b.dfService.writeRTT(40000)
            }
            try? await Task.sleep(for: .milliseconds(200))
            for b in fitnet.biodyns {
                let ticker = Date.currentFitnetTick()
                log.info("[SelfTestNetMode] Setting ticker to \(ticker)")
                b.dfService.writeTicker(ticker)
            }
            try? await Task.sleep(for: .milliseconds(300))
            for b in fitnet.biodyns {
                b.selfTestService.read()
            }
            
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                for b in fitnet.biodyns {
                    b.selfTestService.read()
                    b.dfService.readTicker()
                    await b.selfTestService.readLEDValueAsync()
                    if b.selfTestService.ledValue == true {
                        b.selfTestService.writeLEDValue(value: false)
                    } else {
                        b.selfTestService.writeLEDValue(value: true)
                    }
                }
            }
            
            // Set all back off when done
            for b in fitnet.biodyns {
                b.selfTestService.writeLEDValue(value: false)
            }
        }
    }
    
    public func close() {
        self.readTask?.cancel()
        self.readTask = nil
        log.info("[SelfTestNetMode] Closed")
    }
    
}

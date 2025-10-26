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
    public var isPolling: Bool { get { readTask != nil } }
    public var heartbeat: Heartbeat<B, BDiscovery>

    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        self.heartbeat = Heartbeat(fitnet)
    }
    
    public func start() {
        self.readTask?.cancel()
        
        self.readTask = Task {
            // Do self-tests
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask { await b.selfTestService.runSelfTest() }
                }
            }
            // Write default RTT and ticker
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask {
                        await b.dfService.writeRTT(40000)
                        await b.dfService.writeTicker(Date.currentFitnetTick())
                    }
                }
            }
            // Read self test value
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask { await b.selfTestService.read() }
                }
            }
            
            // Start read loop
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await self.heartbeat.optimizeRTT() }
                    for b in fitnet.biodyns {
                        group.addTask { await b.selfTestService.read() }
                    }
                    for b in fitnet.biodyns {
                        group.addTask {
                            await b.selfTestService.readLEDValue()
                            if b.selfTestService.ledValue == true {
                                await b.selfTestService.writeLEDValue(value: false)
                            } else {
                                await b.selfTestService.writeLEDValue(value: true)
                            }
                        }
                    }
                }
            }
            
            // Set all back off when done
            for b in fitnet.biodyns {
                await b.selfTestService.writeLEDValue(value: false)
            }
        }
    }
    
    public func close() {
        self.readTask?.cancel()
        self.readTask = nil
        log.info("[SelfTestNetMode] Closed")
    }
    
}

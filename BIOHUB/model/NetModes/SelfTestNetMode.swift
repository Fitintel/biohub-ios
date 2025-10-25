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
            // Do self-tests
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask { await b.selfTestService.runSelfTest() }
                }
                await group.waitForAll()
            }
            // Write RTT and ticker
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask {
                        await b.dfService.writeRTT(40000)
                        await b.dfService.writeTicker(Date.currentFitnetTick())
                    }
                }
                await group.waitForAll()
            }
            // Read self test value
            await withTaskGroup(of: Void.self) { group in
                for b in fitnet.biodyns {
                    group.addTask { await b.selfTestService.read() }
                }
                await group.waitForAll()
            }
            
            // Start read loop
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                // Values
                await withTaskGroup(of: Void.self) { group in
                    for b in fitnet.biodyns {
                        group.addTask { await b.dfService.readTicker() }
                        group.addTask { await b.selfTestService.read() }
                    }
                    await group.waitForAll()
                }
                // LED control -> separating makes more in sync
                await withTaskGroup(of: Void.self) { group in
                    for b in fitnet.biodyns {
                        group.addTask {
                            if b.selfTestService.ledValue == true {
                                await b.selfTestService.writeLEDValue(value: false)
                            } else {
                                await b.selfTestService.writeLEDValue(value: true)
                            }
                        }
                    }
                    await group.waitForAll()
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

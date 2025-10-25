//
//  Heartbeat.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-22.
//

import Foundation
import Observation

public class Heartbeat<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
    where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    
    private let fitnet: Fitnet<B, BDiscovery>

    public init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
    }
    
    public func optimizeRTT() async {
        await withTaskGroup(of: Void.self) { group in
            for b in fitnet.biodyns {
                group.addTask {
                    // Measure average error
                    let avgErr = RollingAverage(keepCount: 10)
                    for _ in 0...15 {
                        await b.dfService.readTicker()
                        guard let tickErrMs = b.dfService.tickerErrorMs else { continue }
                        log.info("[Heartbeat] Err \(tickErrMs), avg \(b.avgReadDelay ?? 0)")
                        avgErr.add(tickErrMs)
                    }
                    
                    // Re-read the info we want
                    await b.dfService.readRTT()
                    await b.dfService.readTicker()
                    // Try to get sub 5ms error
                    if avgErr.average! > 5 {
                        guard let measuredRTTMs = b.avgReadDelay else { return }
                        guard let rttBeforeTicks = b.dfService.rtt else { return }
                        let rttBeforeMs = Double(rttBeforeTicks) / 1000.0
                        log.info("[Heartbeat] Current RTT on device \(String(format: "%.1f", rttBeforeMs))ms, measured \(String(format: "%.1f", measuredRTTMs))ms, error of \(String(format: "%.1f", avgErr.average!))")
                    }
                }
            }
        }
    }
    
    public func tickerError(_ b: B) -> Int64 {
        if b.dfService.ticker == nil {
            return 0
        }
        return Int64(Int128(Date.currentFitnetTick()) - Int128(b.dfService.ticker!))
    }
    
}

extension Date {
    public static func currentFitnetTick() -> UInt64 {
        return Date.now.asFitnetTick()
    }
    public static func fromFitnetTick(_ tick: UInt64) -> Date {
        return Date.init(timeIntervalSince1970: Double(tick) / 1_000_000)
    }
    public func asFitnetTick() -> UInt64 {
        return UInt64(self.timeIntervalSince1970 * 1_000_000)
    }
}

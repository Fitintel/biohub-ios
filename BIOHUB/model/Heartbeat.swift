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
    let tag: String = "Heartbeat"

    public init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
    }
    
    public func optimizeRTT(measurements: Int = 6) async {
        await withTaskGroup(of: Void.self) { group in
            for b in fitnet.biodyns {
                group.addTask {
                    // Measure average error
                    let avgErr = RollingAverage(keepCount: measurements)
                    for _ in 0...(measurements - 1) {
                        await b.dfService.readTicker()
                        guard let tickErrMs = b.dfService.tickerErrorMs else { continue }
                        avgErr.add(tickErrMs)
                    }
                    guard avgErr.average != nil else {
                        log.error("[\(self.tag)] Did not get any readings to tune heartbeat")
                        return
                    }

                    // Re-read the info we want
                    await b.dfService.readRTT()
                    
                    // Hard-set if we're super far
                    if abs(avgErr.average!) > 500 {
                        await b.dfService.writeRTT(b.avgReadDelay?.msToTicks() ?? 45_000)
                        log.info("[\(self.tag)] hard setting")
                        await self.optimizeRTT(measurements: 3) // Retry to reduce error
                    } else if abs(avgErr.average!) > 2 {
                        guard let rttBeforeTicks = b.dfService.rtt else { return }
                        let rttBeforeMs = Double(rttBeforeTicks) / 1000.0
                        // Adjust by half error
                        let newRttMs = rttBeforeMs + (avgErr.average! / 2.0)
                        log.info("[\(self.tag)] Shifting \(b.deviceInfoService.systemIdStr ?? "???") RTT \(String(format: "%.1f", rttBeforeMs))ms to \(String(format: "%.1f", newRttMs))ms")
                        await b.dfService.writeRTT(newRttMs.msToTicks())
                        await b.dfService.writeTicker(Date.currentFitnetTick())
                    }
                }
            }
        }
        log.info("[\(self.tag)] Optimized RTT")
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

extension Double {
    public func msToTicks() -> UInt64 {
        return UInt64(self * 1000)
    }
}

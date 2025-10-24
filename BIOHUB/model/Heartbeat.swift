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
        // TODO: need write async first though
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
        return UInt64(Date.now.timeIntervalSince1970 * 1_000_000)
    }
}

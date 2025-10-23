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
    
}

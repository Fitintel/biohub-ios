//
//  NetManager.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
public class Fitnet<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = PeripheralsManager<B, BDiscovery>

    public var biodyns: [B] { get { peripheralsManager.biodyns } }
    
    public let peripheralsManager: PM
    
    init(_ peripheralsManager: PM) {
        self.peripheralsManager = peripheralsManager
    }
}

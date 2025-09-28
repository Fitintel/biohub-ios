//
//  PeripheralsManager.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
public class PeripheralsManager<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>: PeripheralsDiscoveryListener
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias Peripheral = B
    
    public var biodyns: [B]
    public var hasBiodyns: Bool { get { return biodyns.count > 0 }}
    public let biodynDiscovery: BDiscovery
    
    init(biodynDiscovery: BDiscovery) {
        self.biodynDiscovery = biodynDiscovery
        self.biodyns = []
        
        self.biodynDiscovery.addListener(self)
    }
    
    // Callback for when a BIODYN is discovered
    public func onConnected(_ p: B) {
        self.biodyns.append(p)
    }
    
    // Callback for when a BIODYN is disconnected
    public func onDisconnected(_ p: B) {
        self.biodyns.removeAll(where: { b in
            b.uuid == p.uuid
        })
    }
    
}

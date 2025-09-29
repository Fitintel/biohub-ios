//
//  SelfTestNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
public class SelfTestNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = Fitnet<B, BDiscovery>

    public let fitnet: Fitnet<B, BDiscovery>
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        self.runSelfTest()
    }
    
    public func runSelfTest() {
        fitnet.biodyns.forEach({ b in b.selfTestService.runSelfTest() })
    }
    
}

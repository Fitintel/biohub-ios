//
//  DataCollectionNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-29.
//

import Observation

@Observable
public class DataCollectionNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>> : PollingNetMode<B, BDiscovery, FullDataStream>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = Fitnet<B, BDiscovery>

        init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "Data Collection Net Mode", fitnet: fitnet)
    }
    
}

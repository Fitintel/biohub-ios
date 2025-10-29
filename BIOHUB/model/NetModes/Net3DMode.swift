//
//  Net3DMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-28.
//

import Observation
import Foundation

@Observable
public class Net3DMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>> : DataCollectionNetMode<B, BDiscovery>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    
    override public init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(fitnet)
    }
    
    public override func readAsync() async {
        await super.readAsync()
    }
    
}

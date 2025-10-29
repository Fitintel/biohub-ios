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
    
    public private(set)var b3ds: [UUID: Biodyn3D<B, BDiscovery>] = [:]
    
    override public init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(fitnet)
        updateB3ds()
    }
    
    public func resetPositions() {
        for b in b3ds.values {
            b.resetPosition()
        }
    }
    
    public override func readAsync() async {
        // Ensure we have b3ds
        updateB3ds()
        // Read from devices
        await super.readAsync()
        // Calculate new things
        for b in b3ds.values {
            b.calcPosition()
        }
    }
    
    private func updateB3ds() {
        // Remove ones that aren't present anymore
        var toRemove: [UUID] = []
        for b in b3ds.values {
            if !fitnet.biodyns.contains(where: { x in x.uuid == b.biodyn.uuid}) {
                toRemove.append(b.biodyn.uuid)
            }
        }
        for tr in toRemove {
            b3ds.removeValue(forKey: tr)
        }
        // Add new ones
        for b in fitnet.biodyns {
            if b3ds[b.uuid] == nil {
                b3ds.updateValue(Biodyn3D(b), forKey: b.uuid)
            }
        }
    }
    
}

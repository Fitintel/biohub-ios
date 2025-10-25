//
//  EMGNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import Observation
import Foundation

@Observable
public class EMGNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>> : PollingNetMode<B, BDiscovery,  FloatDataStream>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    
    public let maxEMG: Float = 5
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "EMGNetMode", fitnet: fitnet)
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.dfService.read()
                    if biodyn.dfService.emg != nil {
                        self.ensureStream(biodyn).addAll(biodyn.dfService.emg!)
                    }
                }
            }
        }
    }
    
}

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

    init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "Data Collection Net Mode", fitnet: fitnet)
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.dfService.readAsync()
                    let stream = self.ensureStream(biodyn)
                    
                    if biodyn.dfService.emg == nil { return }
                    stream.emg.addAll(biodyn.dfService.emg!)
                    
                    if biodyn.dfService.planarAccel == nil { return }
                    stream.imu.addAllPlanar(biodyn.dfService.planarAccel!)
                    
                    if biodyn.dfService.gyroAccel == nil { return }
                    stream.imu.addAllGyro(biodyn.dfService.gyroAccel!)
                    
                    if biodyn.dfService.magnetometer == nil { return }
                    stream.imu.addAllMag(biodyn.dfService.magnetometer!)
                }
            }
            
            await group.waitForAll()
        }
    }
    
}

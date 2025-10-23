//
//  IMUNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Observation
import Foundation

@Observable
public class IMUNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>> : PollingNetMode<B, BDiscovery,  IMUDataStream>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    
    public let maxPlanarAccel: Float = 30 // m/s^2
    public let maxGyroAccel: Float = 720 // deg/s
    public let maxMagnetometer: Float = 5
    public let avgReadDelay: Double = 0
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "IMUNetMode", fitnet: fitnet)
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.dfService.readIMUAsync()
                    let readTime = Date.now
                    if biodyn.dfService.planarAccel != nil {
                        self.ensureStream(biodyn).addAllPlanar(biodyn.dfService.planarAccel!)
                    }
                    if biodyn.dfService.gyroAccel != nil {
                        self.ensureStream(biodyn).addAllGyro(biodyn.dfService.gyroAccel!)
                    }
                    if biodyn.dfService.magnetometer != nil {
                        self.ensureStream(biodyn).addAllMag(biodyn.dfService.magnetometer!)
                    }
                }
            }
            await group.waitForAll()
        }
    }
    
}

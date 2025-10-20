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
    public let maxGyroAccel: Float = 720 // deg\s
    public let maxMagnetometer: Float = 5
    public let avgReadDelay: Double = 0
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "IMUNetMode", fitnet: fitnet)
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.imuService.readPlanarAccelAsync()
                    let readTime = Date.now
                    if biodyn.imuService.planarAccel == nil { return }
                    self.ensureStream(biodyn).addPlanar(
                        DatedFloat3(readTime: readTime, read: biodyn.imuService.planarAccel!)
                    )
                }
                group.addTask {
                    await biodyn.imuService.readGyroAccelAsync()
                    let readTime = Date.now
                    if biodyn.imuService.gyroAccel == nil { return }
                    self.ensureStream(biodyn).addGyro(
                        DatedFloat3(readTime: readTime, read: biodyn.imuService.gyroAccel!)
                    )
                }
//                group.addTask {
//                    await biodyn.imuService.readMagnetometerAsync()
//                    let readTime = Date.now
//                    if biodyn.imuService.magnetometer == nil { return }
//                    self.ensureStream(biodyn).addMag(
//                        DatedFloat3(readTime: readTime, read: biodyn.imuService.magnetometer!)
//                    )
//                }
            }
            await group.waitForAll()
        }
    }
    
}

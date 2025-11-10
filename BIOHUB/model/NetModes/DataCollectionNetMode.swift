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
    
    public let capacity = RollingAverage(keepCount: 50)
    public let maxPlanarAccel: Float = 30 // m/s^2
    public let maxGyroAccel: Float = 720 // deg/s
    public let maxEmg: Float = 6
    public let maxMagnetometer: Float = 200 // uT
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        super.init(name: "DataCollectionNetMode", fitnet: fitnet)
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.dfService.read()
                    
                    let stream = self.ensureStream(biodyn)
                    
                    if let planar = biodyn.dfService.planarAccel {
                        let beforeCnt = stream.imu.planar.latest.list.count
                        stream.imu.addAllPlanar(planar) // Add planar data
                        let afterCnt = stream.imu.planar.latest.list.count
                        let canTake = planar.list.count
//                        if planar.list.count > 2 {
//                            log.info("Delta is \(planar.list[1].readTime.timeIntervalSince(planar.list[0].readTime) * 1000)ms")
//                        }
                        Task { @MainActor in
                            log.info("Before \(beforeCnt), after \(afterCnt), diff \(afterCnt - beforeCnt)")
                            self.capacity.add(Double(afterCnt - beforeCnt) / Double(canTake)) // Add point difference to read avg taken
                        }
                    }
                    
                    if let emg = biodyn.dfService.emg {
                        stream.emg.addAll(emg) // Add emg data
                    }

                    if let gyro = biodyn.dfService.gyroAccel {
                        stream.imu.addAllGyro(gyro) // Add gyro data
                    }
                    
                    if let mag = biodyn.dfService.magnetometer {
                        stream.imu.addAllMag(mag) // Add mag data
                    }
                    
                    if let orient = biodyn.dfService.orientation {
                        stream.imu.addAllOrientation(orient) // Add orientation data
                    }
                }
            }
        }
    }
    
}

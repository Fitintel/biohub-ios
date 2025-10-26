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
    
    public let heartbeat: Heartbeat<B, BDiscovery>
    public let pointsTakenAvg = RollingAverage(keepCount: 30)
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.heartbeat = Heartbeat(fitnet)
        super.init(name: "DataCollectionNetMode", fitnet: fitnet)
    }
    
    override public func initAsync() async {
        for biodyn in fitnet.biodyns {
            // TODO: set ticker
        }
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.dfService.read()
                    
                    let stream = self.ensureStream(biodyn)
                    
                    if biodyn.dfService.emg != nil {
                        stream.emg.addAll(biodyn.dfService.emg!)
                    }
                    
                    if biodyn.dfService.planarAccel != nil {
                        let beforeCnt = stream.imu.planar.latest.list.count
                        stream.imu.addAllPlanar(biodyn.dfService.planarAccel!) // Add planar data
                        let afterCnt = stream.imu.planar.latest.list.count
                        Task { @MainActor in
                            self.pointsTakenAvg.add(Double(afterCnt - beforeCnt)) // Add point difference to read avg taken
                        }
                    }
                    
                    if biodyn.dfService.gyroAccel != nil {
                        stream.imu.addAllGyro(biodyn.dfService.gyroAccel!) // Add gyro data
                    }
                    
                    if biodyn.dfService.magnetometer != nil {
                        stream.imu.addAllMag(biodyn.dfService.magnetometer!) // Add mag data
                    }
                }
            }
        }
    }
    
}

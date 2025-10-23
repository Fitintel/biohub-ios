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
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.heartbeat = Heartbeat(fitnet)
        super.init(name: "Data Collection Net Mode", fitnet: fitnet)
    }
    
    override public func initAsync() async {
        for biodyn in fitnet.biodyns {
        }
    }
    
    public override func readAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
//                    await biodyn.dfService.readAsync()
                    await biodyn.dfService.readIMUAsync()
                    let stream = self.ensureStream(biodyn)
                    
                    if biodyn.dfService.emg != nil {
                        stream.emg.addAll(biodyn.dfService.emg!)
                    }
                    
                    if biodyn.dfService.planarAccel == nil { return }
                    let beforeCnt = stream.imu.planar.latest.list.count
                    stream.imu.addAllPlanar(biodyn.dfService.planarAccel!)
                    let diff = stream.imu.planar.latest.list.count - beforeCnt
//                    log.info("[\(self.tag)] Added \(diff) new datapoint(s)")
                    
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

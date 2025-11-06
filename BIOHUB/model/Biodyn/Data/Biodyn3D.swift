//
//  Biodyn3D.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-28.
//


import Observation
import simd

@Observable
public class Biodyn3D<B: PBiodyn, BD: PeripheralsDiscovery<B>>
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    public let biodyn: B
    public private(set)var position = SIMD3<Float>(0,0,0)
    public private(set)var velocity = SIMD3<Float>(0,0,0)
    public private(set)var accel = SIMD3<Float>(0,0,0)
    public private(set)var angle = SIMD3<Float>(0,0,0)
    public private(set)var angularVelocity = SIMD3<Float>(0,0,0)
    public private(set)var mag = SIMD3<Float>(0,0,0)
    public private(set)var emg = Float(0)
    
    public init(_ biodyn: B) {
        self.biodyn = biodyn
    }
    
    public func calcPosition() {
        if let planar = biodyn.dfService.planarAccel {
            let gyro = biodyn.dfService.gyroAccel!
            let magList = biodyn.dfService.magnetometer!
            let emgList = biodyn.dfService.emg!
            
            let lastIdx = planar.list.count - 1
            if lastIdx >= 1 { // Need 2 datapoints to take the average
                let elapsed = planar.list[lastIdx].readTime.timeIntervalSince(planar.list[lastIdx-1].readTime)
                
                mag = (magList.list[lastIdx].read + magList.list[lastIdx-1].read) / 2.0
                emg = (emgList.list[lastIdx].read + emgList.list[lastIdx-1].read) / 2.0
                
                angularVelocity = ((gyro.list[lastIdx].read + gyro.list[lastIdx-1].read) / 2) * 2 * Float.pi / 360.0
                angle += angularVelocity * Float(elapsed)

                let accelNotNorm = (planar.list[lastIdx].read + planar.list[lastIdx-1].read) / 2.0
                accel = accelNotNorm - (normalize(mag) * 9.81) // Account for gravity
                velocity += accel * Float(elapsed)
                position += velocity * Float(elapsed)
            }
        }
    }
    
    public func resetPosition() {
        accel = SIMD3<Float>()
        velocity = SIMD3<Float>()
        position = SIMD3<Float>()
        angle = SIMD3<Float>()
        angularVelocity = SIMD3<Float>()
    }
    
}

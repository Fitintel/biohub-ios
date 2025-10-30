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
    
    public init(_ biodyn: B) {
        self.biodyn = biodyn
    }
    
    public func calcPosition() {
        if let planar = biodyn.dfService.planarAccel {
            let gyro = biodyn.dfService.gyroAccel!
            let lastIdx = planar.list.count - 1
            if lastIdx >= 1 { // need enough data
                let elapsed = planar.list[lastIdx].readTime.timeIntervalSince(planar.list[lastIdx-1].readTime)
                accel = (planar.list[lastIdx].read + planar.list[lastIdx-1].read) / 2
                velocity += accel * Float(elapsed)
                position += velocity * Float(elapsed)
                
                angularVelocity = ((gyro.list[lastIdx].read + gyro.list[lastIdx-1].read) / 2) * 2 * Float.pi / 360.0
                angle += angularVelocity * Float(elapsed)
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

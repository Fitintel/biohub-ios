//
//  PIMUService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Observation
import simd

public protocol PIMUService: Observable {
    var planarAccel: SIMD3<Float>? { get }
    var gyroAccel: SIMD3<Float>? { get }
    var magnetometer: SIMD3<Float>? { get }
    
    func readPlanarAccel()
    func readGyroAccel()
    func readMagnetometer()
}

public extension PIMUService {
    func readAll() {
        readPlanarAccel()
        readGyroAccel()
        readMagnetometer()
    }
}

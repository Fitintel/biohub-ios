//
//  TestIMUService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

public class TestIMUService: PIMUService, TestWithDelays {
    public var planarAccel: SIMD3<Float>?
    public var gyroAccel: SIMD3<Float>?
    public var magnetometer: SIMD3<Float>?
    
    private var rng = SystemRandomNumberGenerator()
    
    private func randomFloat(_ max: Float) -> Float {
        let v = rng.next(upperBound: UInt(2048))
        return Float(v) / 2048 * max
    }
    
    private func randomFloat3(_ max: Float) -> SIMD3<Float> {
        return SIMD3<Float>(randomFloat(max), randomFloat(max), randomFloat(max))
    }

    public func readPlanarAccel() {
        doNow {
            if self.planarAccel == nil {
                self.planarAccel = self.randomFloat3(4)
            } else {
                self.planarAccel! += self.randomFloat(0.4) - 0.2
            }
        }
    }
    
    public func readGyroAccel() {
        doNow {
            if self.gyroAccel == nil {
                self.gyroAccel = self.randomFloat3(3)
            } else {
                self.gyroAccel! += self.randomFloat(0.4) - 0.2
            }
        }
    }
    
    public func readMagnetometer() {
        doNow {
            if self.gyroAccel == nil {
                self.gyroAccel = self.randomFloat3(2)
            } else {
                self.gyroAccel! += self.randomFloat(0.2) - 0.1
            }
        }
    }
    
}

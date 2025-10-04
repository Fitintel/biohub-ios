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
    
    private func randomFloat3(_ min: Float, _ max: Float) -> SIMD3<Float> {
        let d = (max - min) / 2
        return randomFloat3(max - min) - SIMD3<Float>(d, d, d)
    }

    public func readPlanarAccel() {
        doNow {
            if self.planarAccel == nil {
                self.planarAccel = self.randomFloat3(4)
            } else {
                if abs(self.planarAccel!.sum()) > 5 {
                    self.planarAccel! *= 0.98
                } else {
                    self.planarAccel! += self.randomFloat3(-0.1, 0.1)
                }
            }
        }
    }
    
    public func readGyroAccel() {
        doNow {
            if self.gyroAccel == nil {
                self.gyroAccel = self.randomFloat3(2)
            } else {
                if abs(self.gyroAccel!.sum()) > 5 {
                    self.gyroAccel! *= 0.98
                } else {
                    self.gyroAccel! += self.randomFloat3(-0.14, 0.14)
                }
            }
        }
    }
    
    public func readMagnetometer() {
        doNow {
            if self.magnetometer == nil {
                self.magnetometer = self.randomFloat3(3)
            } else {
                if abs(self.magnetometer!.sum()) > 5 {
                    self.magnetometer! *= 0.98
                } else {
                    self.magnetometer! += self.randomFloat3(-0.05, 0.05)
                }
            }
        }
    }
    
}

//
//  TestIMUService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Observation
import Foundation

@Observable
public class TestIMUService: PIMUService, TestWithDelays {
    
    public var planarAccel: SIMD3<Float>?
    public var gyroAccel: SIMD3<Float>?
    public var magnetometer: SIMD3<Float>?
    
    public var pi: SIMD3<Float>?
    public var gi: SIMD3<Float>?
    public var mi: SIMD3<Float>?

    private var updateTask: Task<Void, Never>?
    private var rng = SystemRandomNumberGenerator()

    init() {
        updateTask = Task {
            while !Task.isCancelled {
                let interval: Duration = .milliseconds(6)
                self.simulatePlanar()
                self.simulateGyro()
                self.simulateMag()
                try? await Task.sleep(for: interval)
            }
        }
    }

    public func readPlanarAccel() {
        doNow { self.planarAccel = self.pi }
    }
    
    public func readGyroAccel() {
        doNow { self.gyroAccel = self.gi }
    }
    
    public func readMagnetometer() {
        doNow { self.magnetometer = self.mi }
    }
    
    public func readPlanarAccelAsync() async {
        try? await Task.sleep(for: .milliseconds(10))
        planarAccel = pi
    }
    
    public func readGyroAccelAsync() async {
        try? await Task.sleep(for: .milliseconds(10))
        gyroAccel = gi
    }
    
    public func readMagnetometerAsync() async {
        try? await Task.sleep(for: .milliseconds(10))
        magnetometer = mi
    }
    
    private func simulatePlanar() {
        if self.pi == nil {
            self.pi = self.randomFloat3(1)
        } else {
            jumpUpOrDown(data: &self.pi!)
            if abs(self.pi!.sum()) > 10 {
                self.pi! *= self.randomFloat(0.4, 0.999)
            } else {
                self.pi! += self.randomFloat3(-0.1, 0.1)
            }
            clampComponentsTo(&pi, 4.5)
        }
    }
    
    private func simulateGyro() {
        if self.gi == nil {
            self.gi = self.randomFloat3(0.5)
        } else {
            jumpUpOrDown(data: &self.gi!)
            if abs(self.gi!.sum()) > 10 {
                self.gi! *= self.randomFloat(0.7, 0.98)
            } else {
                self.gi! += self.randomFloat3(-0.14, 0.14)
            }
            clampComponentsTo(&gi, 4.5)
        }
    }
    
    private func simulateMag() {
        if self.mi == nil {
            self.mi = self.randomFloat3(1)
        } else {
            if abs(self.mi!.sum()) > 5 {
                self.mi! *= self.randomFloat(0.8, 0.999)
            } else {
                self.mi! += self.randomFloat3(-0.05, 0.05)
            }
            clampComponentsTo(&mi, 3)
        }
    }
    
    private func jumpUpOrDown(data: inout SIMD3<Float>) {
        if randomFloat(10) > 9.68 {
            let rf = randomFloat(10)
            if rf < 3.3 {
                data.x *= self.randomFloat(-2, 2)
            } else if rf < 6.6 {
                data.y *= self.randomFloat(-2, 2)
            } else {
                data.z *= self.randomFloat(-2, 2)
            }
        }
        else if randomFloat(10) > 9.6 {
            let rf = randomFloat(10)
            if rf < 3.3 {
                data.x *= self.randomFloat(-1.1, 1.1)
            } else if rf < 6.6 {
                data.y *= self.randomFloat(-1.1, 1.1)
            } else {
                data.z *= self.randomFloat(-1.1, 1.1)
            }
        }
    }
    
    private func clampComponentsTo(_ simd: inout SIMD3<Float>?, _ max: Float) {
        if simd != nil {
            simd!.x = min(max, simd!.x)
            simd!.y = min(max, simd!.y)
            simd!.z = min(max, simd!.z)
        }
    }

    private func randomFloat(_ max: Float) -> Float {
        let v = rng.next(upperBound: UInt(2048))
        return Float(v) / 2048 * max
    }
    
    private func randomFloat(_ min: Float, _ max: Float) -> Float {
        let d = (max - min) / 2
        return randomFloat(max - min) - d
    }
    
    private func randomFloat3(_ max: Float) -> SIMD3<Float> {
        return SIMD3<Float>(randomFloat(max), randomFloat(max), randomFloat(max))
    }
    
    private func randomFloat3(_ min: Float, _ max: Float) -> SIMD3<Float> {
        let d = (max - min) / 2
        return randomFloat3(max - min) - SIMD3<Float>(d, d, d)
    }

}

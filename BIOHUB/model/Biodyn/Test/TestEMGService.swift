//
//  TestEMGService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import Observation
import Foundation

@Observable
public class TestEMGService: PEMGService, TestWithDelays {
    public var emg: Float?
    
    public var inst: Float?
    
    private var updateTask: Task<Void, Never>?
    private var rng = SystemRandomNumberGenerator()
    
    private let circBufLen = 500
    private var historyWritePtr: Int = 0
    private var history: [DatedFloat] = []
    private var historyStart: Date = Date.now
    private var historyEnd: Date = Date.now

    init() {
        updateTask = Task {
            while !Task.isCancelled {
                let interval: Duration = .milliseconds(5)
                self.simulate()
                try? await Task.sleep(for: interval)
            }
        }
    }
    
    public func readEMG() {
        doNow {
            self.emg = self.inst
        }
    }
    
    public func readEMGAsync() async {
        try? await Task.sleep(nanoseconds: 100)
        self.emg = self.inst
    }

    private func simulate() {
        if self.inst == nil {
            self.inst = self.randomFloat(0.5)
        } else {
            if abs(self.inst!) > 5 {
                self.inst! *= self.randomFloat(0.4, 0.999)
            } else {
                self.inst! += self.randomFloat(-0.1, 0.1)
            }
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
}

//
//  TestDataFastService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-09.
//

import Observation
import Foundation

@Observable
public class TestDataFastService: PDataFastService, TestWithDelays {
    public var emg: DatedFloatList?
    public var planarAccel: DatedFloat3List?
    public var gyroAccel: DatedFloat3List?
    public var magnetometer: DatedFloat3List?
    public var sampleStart: Date?
    public var sampleEnd: Date?
    
    private var cEmg: [Float] = []
    private var cPlanar: [SIMD3<Float>] = []
    private var cGyro: [SIMD3<Float>] = []
    private var cMag: [SIMD3<Float>] = []
    private var start: Date = Date.now
    private var end: Date = Date.now

    private let emgS: TestEMGService
    private let imuS: TestIMUService
    private var updateTask: Task<Void, Never>?
    private let measurements = 100

    public init(_ emgService: TestEMGService, _ imuService: TestIMUService) {
        self.emgS = emgService
        self.imuS = imuService
        
        updateTask = Task {
            while !Task.isCancelled {
                let interval: Duration = .milliseconds(19)
                await self.simulate()
                try? await Task.sleep(for: interval)
            }
        }
    }
    
    public func read() {
        doImmediately { self.syncWithInternal() }
    }
    
    public func readAsync() async {
        try? await Task.sleep(for: .milliseconds(5))
        self.syncWithInternal()
    }
    
    private func syncWithInternal() {
        self.emg = DatedFloatList.interpolate(samples: cEmg, start: start, end: end)
        self.planarAccel = DatedFloat3List.interpolate(samples: cPlanar, start: start, end: end)
        self.gyroAccel = DatedFloat3List.interpolate(samples: cGyro, start: start, end: end)
        self.magnetometer = DatedFloat3List.interpolate(samples: cMag, start: start, end: end)
    }
    
    private func simulate() async {
        // TODO: me
    }


}
    

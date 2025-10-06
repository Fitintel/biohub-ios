//
//  IMUNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Observation
import Foundation

@Observable
public class IMUNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = Fitnet<B, BDiscovery>
    private let TAG = "IMUNetMode"
    
    public let maxPlanarAccel: Float = 5
    public let maxGyroAccel: Float = 5
    public let maxMagnetometer: Float = 5
    
    public let fitnet: Fitnet<B, BDiscovery>
    public var isPolling: Bool { get { return pollTask != nil } }
    
    private var dataMap = Dictionary<UUID, IMUDataStream>()
    private var pollTask: Task<Void, Never>? = nil
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        for biodyn in fitnet.biodyns {
            dataMap.updateValue(IMUDataStream(), forKey: biodyn.uuid)
        }
    }
    
    public func dataFor(_ biodyn: B) -> IMUDataStream {
        return self.ensureStream(biodyn)
    }
    
    @MainActor
    public func reset() {
        for biodyn in fitnet.biodyns {
            self.ensureStream(biodyn).reset()
        }
    }
    
    public func startPolling() {
        log.info("[\(self.TAG)] Starting polling")
        self.pollTask = Task {
            let interval: Duration = .milliseconds(20)
            while !Task.isCancelled {
                await timerFired()
                try? await Task.sleep(for: interval)
            }
        }
    }
    
    @MainActor
    public func stopPolling() {
        log.info("[\(self.TAG)] Stopping polling")
        self.pollTask?.cancel()
        self.pollTask = nil
        
        for biodyn in fitnet.biodyns {
            self.ensureStream(biodyn).startNewSegment()
        }
    }
    
    private func timerFired() async {
        await withTaskGroup(of: Void.self) { group in
            for biodyn in fitnet.biodyns {
                group.addTask {
                    await biodyn.imuService.readPlanarAccelAsync()
                    let readTime = Date.now
                    if biodyn.imuService.planarAccel == nil { return }
                    await MainActor.run {
                        self.ensureStream(biodyn).addPlanar(
                            DatedSIMD3F(readTime: readTime, read: biodyn.imuService.planarAccel!)
                        )
                    }
                }
                group.addTask {
                    await biodyn.imuService.readGyroAccelAsync()
                    let readTime = Date.now
                    if biodyn.imuService.gyroAccel == nil { return }
                    await MainActor.run {
                        self.ensureStream(biodyn).addGyro(
                            DatedSIMD3F(readTime: readTime, read: biodyn.imuService.gyroAccel!)
                        )
                    }
                }
                group.addTask {
                    await biodyn.imuService.readMagnetometerAsync()
                    let readTime = Date.now
                    if biodyn.imuService.magnetometer == nil { return }
                    await MainActor.run {
                        self.ensureStream(biodyn).addMag(
                            DatedSIMD3F(readTime: readTime, read: biodyn.imuService.magnetometer!)
                        )
                    }
                }
            }
            await group.waitForAll()
        }
    }
    
    private func ensureStream(_ biodyn: B) -> IMUDataStream {
        if let s = dataMap[biodyn.uuid] { return s }
        let s = IMUDataStream()
        dataMap[biodyn.uuid] = s
        return s
    }
    
    @Observable
    public class IMUDataStream {
        public var planar = DatedSIMD3FSegments()
        public var gyro = DatedSIMD3FSegments()
        public var magneto = DatedSIMD3FSegments()
        
        @MainActor
        public func addPlanar(_ v: DatedSIMD3F) {
            self.planar.latest.append(v)
        }
        
        @MainActor
        public func addGyro(_ v: DatedSIMD3F) {
            self.gyro.latest.append(v)
        }
        
        @MainActor
        public func addMag(_ v: DatedSIMD3F) {
            self.magneto.latest.append(v)
        }
        
        @MainActor
        public func reset() {
            self.planar.reset()
            self.gyro.reset()
            self.magneto.reset()
        }
        
        @MainActor
        public func startNewSegment() {
            self.planar.startNewSegment()
            self.gyro.startNewSegment()
            self.magneto.startNewSegment()
        }
    }
    
}

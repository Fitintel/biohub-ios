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
    
    public let fitnet: Fitnet<B, BDiscovery>
    public var isPolling: Bool { get { return pollTask != nil } }
    
    private var dataMap = Dictionary<UUID, IMUDataStream>()
    private var pollTask: Task<Void, Never>? = nil

    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        
        // Set up data streams
        for biodyn in fitnet.biodyns {
            dataMap.updateValue(IMUDataStream(), forKey: biodyn.uuid)
        }
    }
    
    deinit {
        stopPolling()
    }
    
    public func dataFor(_ biodyn: B) -> IMUDataStream? {
        return dataMap[biodyn.uuid]
    }

    public func startPolling() {
        log.info("[\(self.TAG)] Starting polling")
        self.pollTask = Task {
            let interval: Duration = .milliseconds(50)
            while !Task.isCancelled {
                await timerFired()
                try? await Task.sleep(for: interval)
            }
        }
    }
    
    public func stopPolling() {
        log.info("[\(self.TAG)] Stopping polling")
        self.pollTask?.cancel()
        self.pollTask = nil
    }
    
    private func timerFired() async {
        for biodyn in fitnet.biodyns {
            await biodyn.imuService.readPlanarAccelAsync()
            if biodyn.imuService.planarAccel == nil {
                continue
            }
            dataMap[biodyn.uuid]!.planarX.append(biodyn.imuService.planarAccel!.x)
            dataMap[biodyn.uuid]!.planarY.append(biodyn.imuService.planarAccel!.y)
            dataMap[biodyn.uuid]!.planarZ.append(biodyn.imuService.planarAccel!.z)
        }
    }
    
    @Observable
    public class IMUDataStream {
        public var planarX: [Float] = []
        public var planarY: [Float] = []
        public var planarZ: [Float] = []
    }
    
}

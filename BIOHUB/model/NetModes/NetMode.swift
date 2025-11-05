//
//  NetModes.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Foundation

enum NetMode { case selfTest, dataCollection, net3d }

@Observable
public class PollingNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>, D: Segmentable>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B>,
      D: Encodable & Decodable & DefaultInit {
    
    public let tag: String
    public let fitnet: Fitnet<B, BDiscovery>
    public var isPolling: Bool { get { return pollTask != nil } }
   
    public var dataMap = Dictionary<UUID, D>()
    private var pollTask: Task<Void, Never>? = nil
    public let heartbeat: Heartbeat<B, BDiscovery>
    
    init(name: String, fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        self.tag = name
        self.heartbeat = Heartbeat(fitnet)
        for biodyn in fitnet.biodyns {
            dataMap.updateValue(D(), forKey: biodyn.uuid)
        }
    }
    
    // OVERRIDE ME
    open func readAsync() async {
        log.error("UNIMPLEMENTED POLL NET MODE")
    }
    
    open func initAsync() async {}

    public func dataFor(_ biodyn: B) -> D {
        return self.ensureStream(biodyn)
    }
    
    public func collectedData() -> Dictionary<String, D> {
        var d = Dictionary<String, D>()
        for kvp in dataMap {
            guard let devName = fitnet.byUUID(kvp.key)?.deviceInfoService.systemIdStr else {
                log.warning("[\(self.tag)] Skipping unnamed biodyn \(kvp.key)")
                continue
            }
            d.updateValue(kvp.value, forKey: "\(devName)")
        }
        return d
    }
    
    public func reset() {
        for biodyn in fitnet.biodyns {
            self.ensureStream(biodyn).reset()
        }
    }
    
    public func startPolling() {
        log.info("[\(self.tag)] Starting polling")
        self.pollTask = Task {
            await heartbeat.optimizeRTT()
            await self.initAsync()
            let interval: Duration = .milliseconds(5)
            while !Task.isCancelled {
                await readAsync()
                try? await Task.sleep(for: interval)
            }
            for biodyn in fitnet.biodyns {
                self.ensureStream(biodyn).startNewSegment()
            }
        }
    }
    
    public func stopPolling() {
        log.info("[\(self.tag)] Stopping polling")
        self.pollTask?.cancel()
        self.pollTask = nil
    }
    
    public func ensureStream(_ biodyn: B) -> D {
        if let s = dataMap[biodyn.uuid] { return s }
        let s = D()
        dataMap[biodyn.uuid] = s
        return s
    }
    
}

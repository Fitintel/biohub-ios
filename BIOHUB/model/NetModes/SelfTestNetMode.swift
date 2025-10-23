//
//  SelfTestNetMode.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
public class SelfTestNetMode<B: PBiodyn, BDiscovery: PeripheralsDiscovery<B>>
where BDiscovery.Listener == any PeripheralsDiscoveryListener<B> {
    public typealias PM = Fitnet<B, BDiscovery>
    
    public let fitnet: Fitnet<B, BDiscovery>
    private var readTask: Task<Void, Never>? = nil
    
    init(_ fitnet: Fitnet<B, BDiscovery>) {
        self.fitnet = fitnet
        //        self.start()
    }
    
    public func start() {
        self.readTask?.cancel()
        self.readTask = Task {
            for b in fitnet.biodyns {
                b.selfTestService.runSelfTest()
            }
            try? await Task.sleep(for: .milliseconds(150))
            for b in fitnet.biodyns {
                b.selfTestService.read()
            }
            
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                for b in fitnet.biodyns {
                    b.selfTestService.read()
                    await b.selfTestService.readLEDValueAsync()
                    if b.selfTestService.ledValue == true {
                        b.selfTestService.writeLEDValue(value: false)
                    } else {
                        b.selfTestService.writeLEDValue(value: true)
                    }
                }
            }
            
            // Set all back off when done
            for b in fitnet.biodyns {
                b.selfTestService.writeLEDValue(value: false)
            }
        }
    }
    
    public func close() {
        self.readTask?.cancel()
        self.readTask = nil
        log.info("[SelfTestNetMode] Closed")
    }
    
}

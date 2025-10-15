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
        self.runSelfTest()
        self.start()
    }
    
    public func runSelfTest() {
        fitnet.biodyns.forEach({ b in b.selfTestService.runSelfTest() })
    }
    
    public func start() {
        self.readTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                fitnet.biodyns.forEach({ b in b.selfTestService.read() })
            }
        }
    }

    public func close() {
        self.readTask?.cancel()
        self.readTask = nil
    }
    
}

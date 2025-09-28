//
//  TestPeripheralsDiscovery.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestPeripheralsDiscovery: PeripheralsDiscovery {
    
    typealias Peripheral = TestBiodyn
    typealias Listener = PeripheralsDiscoveryListener<Peripheral>
    
    public var isDiscoverySupported: Bool = true
    public var isDiscovering: Bool = true
    
    private var biodynListeners: [any Listener] = []
    private var biodyns: [Peripheral] = []

    init() {
        log.info("[TestDiscovery] USING DUMMY DATA.")
        addBiodynAfterDelay(seconds: 5)
        removeBiodynAfterDelay(seconds: 10)
    }
    
    func addBiodynAfterDelay(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if self.isDiscovering {
                var b = TestBiodyn()
                self.biodyns.append(b)
                self.biodynListeners.forEach({ l in l.onConnected(b)})
                log.info("[TestDiscovery] Added test BIODYN.")
            }
        }
    }
    
    func removeBiodynAfterDelay(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            guard let b = self.biodyns.first else {
                log.warning("[TestDiscovery] No BIODYNs to remove.")
                return
            }
            self.biodynListeners.forEach({ l in l.onDisconnected(b)})
            log.info("[TestDiscovery] Removed test BIODYN.")
        }
    }
    
    func addListener(_ l: any Listener) {
        self.biodynListeners.append(l)
    }

    public func getDiscoveryError() -> String {
        return "Sadly we just can't do anything."
    }
    
    public func stopDiscovery() {
        isDiscovering = false
    }
    
    public func startDiscovery() {
        isDiscovering = true
    }

    
}

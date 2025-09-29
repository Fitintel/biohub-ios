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
        self.addBiodynAfterDelay(seconds: 0.5)
        self.addBiodynAfterDelay(seconds: 1)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            if self?.biodyns.count ?? 3 < 3 {
                self?.addBiodynAfterDelay(seconds: 0.1)
            }
        }
    }
    
    func disconnect(_ p: TestBiodyn) {
        self.biodyns.removeAll(where: { b in b.uuid == p.uuid})
        self.biodynListeners.forEach({ l in l.onDisconnected(p)})
        log.info("[TestDiscovery] Disconnected test BIODYN \(p.uuid).")
    }

    func addBiodynAfterDelay(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if self.isDiscovering {
                let b = TestBiodyn()
                self.biodyns.append(b)
                self.biodynListeners.forEach({ l in l.onConnected(b)})
                log.info("[TestDiscovery] Added test BIODYN \(b.uuid).")
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
            log.info("[TestDiscovery] Forcibly removed test BIODYN \(b.uuid).")
        }
    }

    func addListener(_ l: any Listener) {
        self.biodynListeners.append(l)
    }

    public func getDiscoveryError() -> String {
        return "Sadly we just can't do anything because this is a test."
    }
    
    public func stopDiscovery() {
        isDiscovering = false
    }
    
    public func startDiscovery() {
        isDiscovering = true
    }

    
}

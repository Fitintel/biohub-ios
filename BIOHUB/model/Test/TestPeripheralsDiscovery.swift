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
    
    private var timer: Timer?
    private var names = ["Alpha", "Beta", "Omega", "Epsilon", "Zeta", "Chi", "Psi", "Phi", "Kappa", "Sigma"]
    private var manufs = ["CALLUM", "ERIC", "JAKE", "MATTEO", "JONAH"]
    private var versions = ["0.0.1", "0.0.2", "0.0.3", "0.0.4", "0.0.5", "0.0.6", "0.0.7"]
    private let maxDevices = 5

    init() {
        log.info("[TestDiscovery] USING DUMMY DATA.")
        self.startDiscovery()
    }
    
    func disconnect(_ p: TestBiodyn) {
        self.biodyns.removeAll(where: { b in b.uuid == p.uuid})
        self.biodynListeners.forEach({ l in l.onDisconnected(p)})
        log.info("[TestDiscovery] Disconnected test BIODYN \(p.uuid).")
    }

    func addBiodynAfterDelay(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if self.isDiscovering {
                let b = TestBiodyn(name: self.names.randomElement()!,
                                   manuf: self.manufs.randomElement()!,
                                   ver: self.versions.randomElement()!)
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
        timer?.invalidate()
        isDiscovering = false
        log.info("[TestDiscovery] Stopped discovery")
    }
    
    public func startDiscovery() {
        let md = self.maxDevices
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            if self?.biodyns.count ?? md < md {
                self?.addBiodynAfterDelay(seconds: [0.1, 0.2, 0.3, 0.4, 0.5].randomElement()!)
            }
        }
        isDiscovering = true
        log.info("[TestDiscovery] Started discovery")
    }

    
}

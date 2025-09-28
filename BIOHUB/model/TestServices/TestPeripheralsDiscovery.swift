//
//  TestPeripheralsDiscovery.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
class TestPeripheralsDiscovery: PeripheralsDiscovery {
    typealias Peripheral = TestBiodyn
    typealias Listener = PeripheralsDiscoveryListener<TestBiodyn>
    
    public var isDiscoverySupported: Bool = true
    var biodynListeners: [any Listener] = []

    init() {
    }
    
    func addListener(_ l: any Listener) {
        self.biodynListeners.append(l)
    }

    public func getDiscoveryError() -> String {
        return "Sadly we just can't do anything."
    }
    
    
}

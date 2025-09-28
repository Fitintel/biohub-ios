//
//  PeripheralsDiscovery.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public protocol PeripheralsDiscovery<Peripheral>: Observable {
    associatedtype Peripheral
    associatedtype Listener
    
    var isDiscoverySupported: Bool { get }
    
    func getDiscoveryError() -> String
    func addListener(_ l: Listener)
}

public protocol PeripheralsDiscoveryListener<Peripheral> {
    associatedtype Peripheral
    
    func onConnected(_ p: Peripheral)
    func onDisconnected(_ p: Peripheral)
}

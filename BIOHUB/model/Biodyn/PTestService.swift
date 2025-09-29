//
//  PTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public protocol PTestService: Observable {
    var ledValue: Bool? { get }
    var deviceName: String? { get }
    func writeLEDValue(value: Bool)
}

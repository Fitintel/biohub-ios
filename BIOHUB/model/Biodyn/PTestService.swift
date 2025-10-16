//
//  PTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public protocol PTestService: Observable {
    var ledValue: Bool? { get }
    func writeLEDValue(value: Bool) 
    func readLEDValue()
}

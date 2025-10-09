//
//  PEMGService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import Observation
import simd

public protocol PEMGService: Observable {
    var emg: Float? { get }
    
    func readEMG()
    func readEMGAsync() async
    
    // TODO: The rest of it
}

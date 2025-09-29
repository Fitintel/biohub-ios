//
//  PSelfTestService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public protocol PSelfTestService: Observable {
    var selfTestOk: Bool? { get }
    var selfTestError: String? { get }
    
    func runSelfTest()
}

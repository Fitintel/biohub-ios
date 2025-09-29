//
//  PFitnetServices.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

public protocol PBiodyn: Observable {
    associatedtype TDeviceInfo: PDeviceInfoService
    associatedtype TTest: PTestService
    associatedtype TSelfTest: PSelfTestService
    
    // UUID of this device
    var uuid: UUID { get }

    // Device information service
    var deviceInfoService: TDeviceInfo { get }
    
    // Test service
    var testService: TTest { get }
    
    // Self-test service
    var selfTestService: TSelfTest { get }
}

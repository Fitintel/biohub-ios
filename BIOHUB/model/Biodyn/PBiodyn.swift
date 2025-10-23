//
//  PFitnetServices.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

public protocol PBiodyn: Observable, Identifiable {
    associatedtype TDeviceInfo: PDeviceInfoService
    associatedtype TSelfTest: PSelfTestService
    associatedtype TDataFast: PDataFastService
    
    // UUID of this device
    var uuid: UUID { get }

    // Device information service
    var deviceInfoService: TDeviceInfo { get }
    
    // Self-test service
    var selfTestService: TSelfTest { get }
    
    // Data fast service
    var dfService: TDataFast { get }
    
    // Average read delay
    var avgReadDelay: Double { get }
}

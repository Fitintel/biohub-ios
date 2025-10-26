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
    
    // Average read delay in ms
    var avgReadDelay: Double? { get }
    // Average write delay in ms
    var avgWriteDelay: Double? { get }
}


extension PBiodyn {
    var avgCommDelay: Double? { get {
        if let rd = avgReadDelay {
            if let wd = avgWriteDelay {
                return (rd + wd) / 2.0
            } else {
                return rd
            }
        }
        return avgWriteDelay
    }}
}

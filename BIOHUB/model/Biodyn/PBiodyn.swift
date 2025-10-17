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
    associatedtype TTest: PTestService
    associatedtype TSelfTest: PSelfTestService
    associatedtype TIMU: PIMUService
    associatedtype TEMG: PEMGService
    associatedtype TDataFast: PDataFastService
    
    // UUID of this device
    var uuid: UUID { get }

    // Device information service
    var deviceInfoService: TDeviceInfo { get }
    
    // Test service
    var testService: TTest { get }
    
    // Self-test service
    var selfTestService: TSelfTest { get }
    
    // IMU service
    var imuService: TIMU { get }
    
    // EMG service
    var emgService: TEMG { get }
    
    // Data fast service
    var dfService: TDataFast { get }
    
    // Average read delay
    var avgReadDelay: Double { get }
}

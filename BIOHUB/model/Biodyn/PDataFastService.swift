//
//  PDataFastService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-09.
//

import Observation
import Foundation

public protocol PDataFastService: Observable {
    var emg: DatedFloatList? { get }
    var planarAccel: DatedFloat3List? { get }
    var gyroAccel: DatedFloat3List? { get }
    var magnetometer: DatedFloat3List? { get }
    
    func read()
    func readAsync() async
    
    func readIMU()
    func readIMUAsync() async
}

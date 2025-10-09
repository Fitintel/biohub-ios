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
    
    var sampleStart: Date? { get }
    var sampleEnd: Date? { get }
    
    func read()
    func readAsync() async
}

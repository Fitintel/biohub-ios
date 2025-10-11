//
//  FullDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-09.
//

import Observation
import Foundation
import simd

@Observable
public class FullDataStream: Encodable, Decodable, Segmentable, DefaultInit {
    public var imu = IMUDataStream()
    public var emg = FloatDataStream()
    
    public required init() {}
    
    public func startNewSegment() {
        imu.startNewSegment()
        emg.startNewSegment()
    }
    
    public func reset() {
        imu.reset()
        emg.reset()
    }
    

}

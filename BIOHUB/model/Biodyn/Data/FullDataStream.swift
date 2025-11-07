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
    
    private enum CodingKeys: String, CodingKey { case emg, imu }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imu = try container.decode(IMUDataStream.self, forKey: .imu)
        self.emg = try container.decode(FloatDataStream.self, forKey: .emg)
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.emg, forKey: .emg)
        try c.encode(self.imu, forKey: .imu)
    }
    
    
}

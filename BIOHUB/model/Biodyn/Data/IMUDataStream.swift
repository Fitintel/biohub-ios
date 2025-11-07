//
//  IMUDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-06.
//

import Observation
import Foundation
import simd

@Observable
public class IMUDataStream: Encodable, Decodable, Segmentable, DefaultInit {
    public var planar = DatedFloat3Segments()
    public var gyro = DatedFloat3Segments()
    public var magneto = DatedFloat3Segments()
    public var orientation = DatedFloat4Segments()
    
    public required init() {}
    
    public func addPlanar(_ v: DatedFloat3) {
        self.planar.latest.append(v)
    }
    public func addAllPlanar(_ v: DatedFloat3List) {
        self.planar.latest.appendAll(v)
    }
    
    public func addGyro(_ v: DatedFloat3) {
        self.gyro.latest.append(v)
    }
    public func addAllGyro(_ v: DatedFloat3List) {
        self.gyro.latest.appendAll(v)
    }
    
    public func addMag(_ v: DatedFloat3) {
        self.magneto.latest.append(v)
    }
    public func addAllMag(_ v: DatedFloat3List) {
        self.magneto.latest.appendAll(v)
    }
    
    public func addOrientation(_ v: DatedFloat4) {
        self.orientation.latest.append(v)
    }
    public func addAllOrientation(_ v: DatedFloat4List) {
        self.orientation.latest.appendAll(v)
    }
    
    
    public func reset() {
        self.planar.reset()
        self.gyro.reset()
        self.magneto.reset()
        self.orientation.reset()
    }
    
    public func startNewSegment() {
        self.planar.startNewSegment()
        self.gyro.startNewSegment()
        self.magneto.startNewSegment()
        self.orientation.startNewSegment()
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case planar, gyro, mag, orientation }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.planar = try container.decode(DatedQSegments.self, forKey: .planar)
        self.gyro = try container.decode(DatedQSegments.self, forKey: .gyro)
        self.magneto = try container.decode(DatedQSegments.self, forKey: .mag)
        self.orientation = try container.decode(DatedQSegments.self, forKey: .orientation)
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.planar, forKey: .planar)
        try c.encode(self.gyro, forKey: .gyro)
        try c.encode(self.magneto, forKey: .mag)
        try c.encode(self.orientation, forKey: .orientation)
    }
}

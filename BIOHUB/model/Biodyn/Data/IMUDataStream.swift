//
//  IMUDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-06.
//

import Observation
import Foundation

@Observable
public class IMUDataStream: Encodable, Decodable {
    public var planar = DatedSIMD3FSegments()
    public var gyro = DatedSIMD3FSegments()
    public var magneto = DatedSIMD3FSegments()
    
    public init() {}
    
    public func addPlanar(_ v: DatedSIMD3F) {
        self.planar.latest.append(v)
    }
    
    public func addGyro(_ v: DatedSIMD3F) {
        self.gyro.latest.append(v)
    }
    
    public func addMag(_ v: DatedSIMD3F) {
        self.magneto.latest.append(v)
    }
    
    public func reset() {
        self.planar.reset()
        self.gyro.reset()
        self.magneto.reset()
    }
    
    public func startNewSegment() {
        self.planar.startNewSegment()
        self.gyro.startNewSegment()
        self.magneto.startNewSegment()
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case planar, gyro, mag }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.planar = try container.decode(DatedSIMD3FSegments.self, forKey: .planar)
        self.gyro = try container.decode(DatedSIMD3FSegments.self, forKey: .gyro)
        self.magneto = try container.decode(DatedSIMD3FSegments.self, forKey: .mag)
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.planar, forKey: .planar)
        try c.encode(self.gyro, forKey: .gyro)
        try c.encode(self.magneto, forKey: .mag)
    }
}

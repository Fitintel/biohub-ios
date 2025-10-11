//
//  EMGDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//


import Observation
import Foundation

@Observable
public class FloatDataStream: Encodable, Decodable, Segmentable, DefaultInit {
    public var floats = DatedFloatSegments()
    
    public required init() {}
    
    public func add(_ value: DatedFloat) {
        self.floats.latest.append(value)
    }
    
    public func addAll(_ values: DatedFloatList) {
        self.floats.latest.appendAll(values)
    }
    
    public func reset() {
        self.floats.reset()
    }
    
    public func startNewSegment() {
        self.floats.startNewSegment()
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case emg }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.floats = try container.decode(DatedFloatSegments.self, forKey: .emg)
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.floats, forKey: .emg)
    }
}

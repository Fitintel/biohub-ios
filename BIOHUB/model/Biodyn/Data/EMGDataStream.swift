//
//  EMGDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//


import Observation
import Foundation

@Observable
public class EMGDataStream: Encodable, Decodable, Segmentable, DefaultInit {
    public var emg = DatedFloatSegments()
    
    public required init() {}
    
    public func addEmg(_ value: DatedFloat) {
        self.emg.latest.append(value)
    }
    
    public func reset() {
        self.emg.reset()
    }
    
    public func startNewSegment() {
        self.emg.startNewSegment()
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case emg }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.emg = try container.decode(DatedFloatSegments.self, forKey: .emg)
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.emg, forKey: .emg)
    }
}

//
//  DatedSIMD3.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import Foundation
import simd
import Observation

public struct DatedSIMD3F: Identifiable, Encodable, Decodable {
    public let id = UUID()
    public let readTime: Date
    public let read: SIMD3<Float>
    
    public init(readTime: Date, read: SIMD3<Float>) {
        self.readTime = readTime
        self.read = read
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case readTime, read }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        readTime = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .readTime))
        read = try container.decode(SIMD3<Float>.self, forKey: .read)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(readTime.timeIntervalSince1970, forKey: .readTime)
        try? container.encode(read, forKey: .read)
    }
}

@Observable
public class DatedSIMD3FList: Identifiable, Observable, Encodable, Decodable {
    public let id = UUID()
    public var simds: [DatedSIMD3F] = []

    public init() {}
    
    public func append(_ v: DatedSIMD3F) {
        self.simds.append(v)
    }
    
    public func reset() {
        self.simds.removeAll()
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case simds }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simds = try container.decode([DatedSIMD3F].self, forKey: .simds)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(simds, forKey: .simds)
    }
}

@Observable
public class DatedSIMD3FSegments: Encodable, Decodable, Identifiable, Observable {
    public var latest: DatedSIMD3FList { get { segments.last! } }
    
    public let id = UUID()
    public var segments: [DatedSIMD3FList] = [DatedSIMD3FList()]
    
    public init() {}
    
    public func reset() {
        self.segments.removeAll()
        self.segments.append(DatedSIMD3FList())
    }
    
    public func startNewSegment() {
        // If the last one is empty might as well use it
        if latest.simds.count > 0 {
            self.segments.append(DatedSIMD3FList())
        }
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case segments }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        segments = try container.decode([DatedSIMD3FList].self, forKey: .segments)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(segments, forKey: .segments)
    }
}

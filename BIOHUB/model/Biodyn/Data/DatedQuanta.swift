//
//  DatedSIMD3.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import Foundation
import simd
import Observation

public typealias DatedFloat3 = DatedQuanta<SIMD3<Float>>
public typealias DatedFloat3List = DatedQList<SIMD3<Float>>
public typealias DatedFloat3Segments = DatedQSegments<SIMD3<Float>>

public typealias DatedFloat4 = DatedQuanta<SIMD4<Float>>
public typealias DatedFloat4List = DatedQList<SIMD4<Float>>
public typealias DatedFloat4Segments = DatedQSegments<SIMD4<Float>>

public typealias DatedFloat = DatedQuanta<Float>
public typealias DatedFloatList = DatedQList<Float>
public typealias DatedFloatSegments = DatedQSegments<Float>

public typealias Quanta = Decodable & Encodable & CustomStringConvertible

public struct DatedQuanta<T>: Identifiable, Encodable, Decodable
where T: Quanta {
    public let id = UUID()
    public let readTime: Date
    public let read: T
    
    public init(readTime: Date, read: T) {
        self.readTime = readTime
        self.read = read
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case readTime, read }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        readTime = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .readTime))
        read = try container.decode(T.self, forKey: .read)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(readTime.timeIntervalSince1970, forKey: .readTime)
        try? container.encode(read, forKey: .read)
    }
}

@Observable
public class DatedQList<T>: Identifiable, Observable, Encodable, Decodable
where T: Quanta {
    public let id = UUID()
    public var list: [DatedQuanta<T>]
    private var newest = Date.init(timeIntervalSince1970: 0)

    public required init() {
        self.list = []
    }
    public init(_ list: [DatedQuanta<T>]) {
        self.list = list
    }
    
    public func append(_ v: DatedQuanta<T>) {
        self.list.append(v)
    }
    
    public func appendAll(_ v : DatedQList<T>) {
        // Time-aware
        for item in v.list {
            if item.readTime > newest {
                newest = item.readTime
                self.append(item)
            }
        }
    }
    
    public func reset() {
        self.list.removeAll()
    }
    
    public static func interpolate(samples: [T], start: Date, end: Date) -> Self {
        let l = Self()
        let begin = start.timeIntervalSince1970
        let elapsed = end.timeIntervalSince1970 - begin
        for i in samples.indices {
            let dpt = elapsed * (Double(i + 1) / Double(samples.count)) + begin
            let rt = Date(timeIntervalSince1970: dpt)
            l.append(DatedQuanta(readTime: rt, read: samples[i]))
        }
        return l
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case list }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        list = try container.decode([DatedQuanta<T>].self, forKey: .list)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(list, forKey: .list)
    }
}

@Observable
public class DatedQSegments<T>: Encodable, Decodable, Identifiable, Observable
where T: Quanta {
    public var latest: DatedQList<T> { get { segments.last! } }
    
    public let id = UUID()
    public var segments: [DatedQList<T>] = [DatedQList<T>()]
    
    public init() {}
    
    public func reset() {
        self.segments.removeAll()
        self.segments.append(DatedQList<T>())
    }
    
    public func startNewSegment() {
        // If the last one is empty might as well use it
        if segments.count > 0 && latest.list.count > 0 {
            self.segments.append(DatedQList<T>())
        }
    }
    
    // Encoding/decoding
    private enum CodingKeys: String, CodingKey { case segments }
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        segments = try container.decode([DatedQList<T>].self, forKey: .segments)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(segments, forKey: .segments)
    }
}

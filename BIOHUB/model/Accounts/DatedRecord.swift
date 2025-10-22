//
//  IMURecord.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-07.
//

import Foundation

public typealias IMURecord = DatedRecord<IMUDataStream>
public typealias FullDataRecord = DatedRecord<FullDataStream>

public struct DatedRecord<T: Encodable & Decodable>: Encodable, Decodable {
    public let data: Dictionary<String, T>
    public let time: Date
    
    public init(data: Dictionary<String, T>, time: Date) {
        self.data = data
        self.time = time
    }
    
    // Encode/decode
    private enum CodingKeys: String, CodingKey { case data, time }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([String : T].self, forKey: .data)
        self.time =  Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .time))
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.data, forKey: CodingKeys.data)
        try container.encode(self.time.timeIntervalSince1970, forKey: CodingKeys.time)
    }
}

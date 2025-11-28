//
//  TrainingDataStream.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-11-27.
//

import Foundation

public struct TrainingDataStream: Encodable, Decodable {
    
    // Map device name to data
    var data: Dictionary<String, FullDataStream>
    var label: String
}

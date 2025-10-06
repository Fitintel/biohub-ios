//
//  DatedSIMD3.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-05.
//

import Foundation
import simd
import Observation

public struct DatedSIMD3F: Identifiable {
    public let id = UUID()
    public let readTime: Date
    public let read: SIMD3<Float>
}

@Observable
public class DatedSIMD3FList: Identifiable, Observable {
    public let id = UUID()
    public var simds: [DatedSIMD3F] = []
    
    public func append(_ v: DatedSIMD3F) {
        self.simds.append(v)
    }
    
    public func reset() {
        self.simds.removeAll()
    }
}

@Observable
public class DatedSIMD3FSegments {
    public var latest: DatedSIMD3FList { get { segments.last! } }
    
    public let id = UUID()
    public var segments: [DatedSIMD3FList] = [DatedSIMD3FList()]
    
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
}

//
//  DataFastService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-09.
//

import Observation
import Foundation
import CoreBluetooth

@Observable
public class DataFastService: FitnetBLEService, PDataFastService {
    private static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0x14, 0x32])))

    public var emg: DatedFloatList?
    public var planarAccel: DatedFloat3List?
    public var gyroAccel: DatedFloat3List?
    public var magnetometer: DatedFloat3List?
    public var sampleStart: Date?
    public var sampleEnd: Date?
    
    public init(_ peripheral: CBPeripheral) {
        // TODO: this
        
        super.init(peripheral, name: "Data Fast Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [])
    }

    public func read() {
        // TODO: this
    }
    
    public func readAsync() async {
        // TODO: this
    }
    
}

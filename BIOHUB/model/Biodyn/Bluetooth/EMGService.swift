//
//  EMGService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-08.
//

import CoreBluetooth
import Observation

@Observable
public class EMGService: FitnetBLEService, PEMGService {
    
    private static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0xB1, 0x32])))
    private static let VALUE_UUID = CBUUID(data: Data([UInt8]([0xB1, 0x50])))
    private static let ASYNC_READ_TIMEOUT: Duration = .milliseconds(100)

    public var emg: Float?
    
    private let emgChar: FitnetFloatChar
    
    public init(_ peripheral: CBPeripheral) {
        let ec = FitnetFloatChar(peripheral, "EMG Value", Self.VALUE_UUID)
        self.emgChar = ec
        
        super.init(peripheral, name: "EMG Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [ec])
    }
    
    public func readEMG() {
        self.emgChar.readValue()
    }
    
    public func readEMGAsync() async {
        await self.emgChar.readValueAsync(timeout: Self.ASYNC_READ_TIMEOUT)
    }
    
    
}

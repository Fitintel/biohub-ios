//
//  IMUService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import CoreBluetooth
import Observation

@Observable
public class IMUService: FitnetBLEService, PIMUService {
    
    private static let SERVICE_UUID = CBUUID(data: Data([UInt8]([0x3C, 0x32])))
    private static let PLANAR_ACC_UUID = CBUUID(data: Data([UInt8]([0xC3, 0x50])))
    private static let GYRO_ACC_UUID = CBUUID(data: Data([UInt8]([0xC3, 0x51])))
    private static let MAGNETO_UUID = CBUUID(data: Data([UInt8]([0xC3, 0x52])))
    private static let ASYNC_READ_TIMEOUT: Duration = .milliseconds(500)
    
    public var planarAccel: SIMD3<Float>? { get { planarChar.value } }
    public var gyroAccel: SIMD3<Float>? { get { gyroChar.value } }
    public var magnetometer: SIMD3<Float>? { get { magChar.value } }
    
    private let planarChar: FitnetFloat3Char
    private let gyroChar: FitnetFloat3Char
    private let magChar: FitnetFloat3Char
    
    init(_ peripheral: CBPeripheral) {
        let pc = FitnetFloat3Char(peripheral, "Planar Acceleration", Self.PLANAR_ACC_UUID)
        self.planarChar = pc
        
        let gc = FitnetFloat3Char(peripheral, "Gyro Acceleration", Self.GYRO_ACC_UUID)
        self.gyroChar = gc
        
        let mc = FitnetFloat3Char(peripheral, "Magnetometer", Self.MAGNETO_UUID)
        self.magChar = mc
        
        super.init(peripheral,
                   name: "IMU Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [pc, gc, mc])
    }

    public func readPlanarAccel() {
        self.planarChar.readValue()
    }
    
    public func readGyroAccel() {
        self.gyroChar.readValue()
    }
    
    public func readMagnetometer() {
        self.magChar.readValue()
    }
    
    public func readPlanarAccelAsync() async {
        await self.planarChar.readValueAsync(timeout: Self.ASYNC_READ_TIMEOUT)
    }
    
    public func readGyroAccelAsync() async {
        await self.gyroChar.readValueAsync(timeout: Self.ASYNC_READ_TIMEOUT)
    }
    
    public func readMagnetometerAsync() async {
        await self.magChar.readValueAsync(timeout: Self.ASYNC_READ_TIMEOUT)
    }

}

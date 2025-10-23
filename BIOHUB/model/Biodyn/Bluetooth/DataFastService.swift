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
    private static let IMU_COLLECTIVE_UUID = CBUUID(data: Data([UInt8]([0x41, 0x53])))
    private static let PACKED_COLLECTIVE_UUID = CBUUID(data: Data([UInt8]([0x41, 0x55])))
    private static let HEARTBEAT_UUID = CBUUID(data: Data([UInt8]([0x41, 0x57])))
    private static let RTT_UUID = CBUUID(data: Data([UInt8]([0x41, 0x58])))

    public var emg: DatedFloatList? // TODO: me
    public var planarAccel: DatedFloat3List? { get { packedImuChar.planar } }
    public var gyroAccel: DatedFloat3List? { get { packedImuChar.gyro } }
    public var magnetometer: DatedFloat3List? { get { packedImuChar.mag } }
    
    private var packedImuChar: PackedIMUChar
    private var tickerChar: FitnetUInt32Char
    private var rttChar: FitnetUInt32Char

    public init(_ peripheral: CBPeripheral) {
        let pic = PackedIMUChar(peripheral)
        self.packedImuChar = pic
        
        let tic = FitnetUInt32Char(peripheral, "Heartbeat", Self.HEARTBEAT_UUID)
        self.tickerChar = tic
        
        let rtt = FitnetUInt32Char(peripheral, "RTT", Self.RTT_UUID)
        self.rttChar = rtt
        
        super.init(peripheral, name: "Data Fast Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [pic, tic, rtt])
    }

    public func read() {
        // TODO: this
    }
    
    public func readAsync() async {
        // TODO: this
    }
    
    public func readIMU() { packedImuChar.readValue() }
    public func readIMUAsync() async { await packedImuChar.readValueAsync(timeout: .milliseconds(200)) }
    public func readRTT() { rttChar.readValue() }
    public func readRTTAsync() async { await rttChar.readValueAsync(timeout: .milliseconds(500)) }
    public func readTicker() { tickerChar.readValue() }
    public func readTickerAsync() async { await tickerChar.readValueAsync(timeout: .milliseconds(500)) }

    @Observable
    private class PackedIMUChar: FitnetBLEChar {
        
        var planar: DatedFloat3List?
        var gyro: DatedFloat3List?
        var mag: DatedFloat3List?
        
        init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Packed IMU", IMU_COLLECTIVE_UUID)
        }
        
        public override func onLoaded() {
            // No eager read
        }
        
        public override func onRead(_ data: Data) {
            // Convert data to float array
            let floatArray = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self), count: data.count / MemoryLayout<Float>.stride))
            }
            
            var planar: [SIMD3<Float>] = []
            var gyro: [SIMD3<Float>] = []
            var mag: [SIMD3<Float>] = []

            // TODO: first and last float are timestamps
            for i in 0...floatArray.count {
                if i % 10 == 2 {
                    planar.append(SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i]))
                } else if i % 10 == 5 {
                    gyro.append(SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i]))
                } else if i % 10 == 8 {
                    mag.append(SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i]))
                }
            }
            
            let start = Date.init(timeIntervalSinceNow: -0.2)
            let didRead = Date.now
            self.planar = DatedFloat3List.interpolate(samples: planar, start: start, end: didRead)
            self.gyro = DatedFloat3List.interpolate(samples: gyro, start: start, end: didRead)
            self.mag = DatedFloat3List.interpolate(samples: mag, start: start, end: didRead)
            
//            log.info("[\(self.name)] Got \(planar.count) new entries: \(planar.last!.x) \(planar.last!.y) \(planar.last!.z)")
        }
        
        public override func writeValue(data: Data, type: CBCharacteristicWriteType) {
            log.error("[\(self.name)] Cannot write to read-only char")
        }

    }
}

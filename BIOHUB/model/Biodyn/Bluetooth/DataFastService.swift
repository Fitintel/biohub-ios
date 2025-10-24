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
    public var ticker: UInt64? {
        get {
            if tickerChar.value == nil || rttChar.value == nil { return nil }
            return tickerChar.value! + rttChar.value! / 2
        }
    }
    public var tickerError: Int64? {
        get {
            if ticker == nil { return nil }
            return Int64(Int128(tickerChar.tickRead) - Int128(ticker!))
        }
    }
    public var rtt: UInt64? { get { rttChar.value }  }
    
    private var packedImuChar: PackedIMUChar
    private var tickerChar: TickerChar
    private var rttChar: FitnetUInt64Char
    
    public init(_ peripheral: CBPeripheral) {
        let pic = PackedIMUChar(peripheral)
        self.packedImuChar = pic
        
        let tic = TickerChar(peripheral)
        self.tickerChar = tic
        
        let rtt = FitnetUInt64Char(peripheral, "RTT", Self.RTT_UUID)
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
    public func writeRTT(_ value: UInt64) { rttChar.writeValue(value) }
    public func writeTicker(_ value: UInt64) { tickerChar.writeValue(value) }
    
    @Observable
    private class TickerChar: FitnetUInt64Char {
        public var tickRead: UInt64 = 0
        
        public init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Heartbeat", HEARTBEAT_UUID)
        }
        
        override func onRead(_ data: Data) {
            super.onRead(data)
            tickRead = Date.currentFitnetTick()
        }
    }
    
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
            let numFloats = 12
            for i in 0...floatArray.count {
                if i % numFloats == 2 {
                    planar.append(SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i]))
                } else if i % numFloats == 5 {
                    gyro.append(SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i]))
                } else if i % numFloats == 8 {
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

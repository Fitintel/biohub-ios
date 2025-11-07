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
    private static let COLLECTIVE_UUID = CBUUID(data: Data([UInt8]([0x41, 0x53])))
    private static let PACKED_COLLECTIVE_UUID = CBUUID(data: Data([UInt8]([0x41, 0x55])))
    private static let HEARTBEAT_UUID = CBUUID(data: Data([UInt8]([0x41, 0x57])))
    private static let RTT_UUID = CBUUID(data: Data([UInt8]([0x41, 0x58])))
    
    public var emg: DatedFloatList?
    public var planarAccel: DatedFloat3List? { get { packedChar.planar } }
    public var gyroAccel: DatedFloat3List? { get { packedChar.gyro } }
    public var magnetometer: DatedFloat3List? { get { packedChar.mag } }
    public var orientation: DatedFloat4List? { get { packedChar.orient } }
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
    
    private var packedChar: PackedIMUChar
    private var tickerChar: TickerChar
    private var rttChar: FitnetUInt64Char
    
    public init(_ peripheral: CBPeripheral) {
        let pic = PackedIMUChar(peripheral)
        self.packedChar = pic
        
        let tic = TickerChar(peripheral)
        self.tickerChar = tic
        
        let rtt = FitnetUInt64Char(peripheral, "RTT", Self.RTT_UUID)
        self.rttChar = rtt
        
        super.init(peripheral, name: "Data Fast Service",
                   uuid: Self.SERVICE_UUID,
                   characteristics: [pic, tic, rtt])
    }
    
    public func read() async { let _ = await packedChar.readValueAsync(timeout: .milliseconds(500)) }
    public func readRTT() async { let _ = await rttChar.readValueAsync(timeout: .milliseconds(500)) }
    public func readTicker() async { let _ = await tickerChar.readValueAsync(timeout: .milliseconds(500)) }
    public func writeRTT(_ value: UInt64) async { let _ = await rttChar.writeValueAsync(value) }
    public func writeTicker(_ value: UInt64) async { let _ = await tickerChar.writeValueAsync(value) }
    
    @Observable
    private class TickerChar: FitnetUInt64Char {
        public var tickRead: UInt64 = 0
        
        public init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Heartbeat", HEARTBEAT_UUID)
        }
        
        override func onRead(_ data: Data) {
            tickRead = Date.currentFitnetTick()
            super.onRead(data)
        }
    }
    
    @Observable
    private class PackedIMUChar: FitnetBLEChar {
        
        var planar: DatedFloat3List?
        var gyro: DatedFloat3List?
        var mag: DatedFloat3List?
        var emg: DatedFloatList?
        var orient: DatedFloat4List?
        
        init(_ peripheral: CBPeripheral) {
            super.init(peripheral, "Packed Collective", COLLECTIVE_UUID)
        }
        
        public override func onLoaded() {
            // No eager read
        }
        
        public override func onRead(_ data: Data) {
            // Convert data to float array
            let floatArray = data.withUnsafeBytes {
                Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self), count: data.count / MemoryLayout<Float>.stride))
            }
            
            var planar: [DatedFloat3] = []
            var gyro: [DatedFloat3] = []
            var mag: [DatedFloat3] = []
            var newEmg: [DatedFloat] = []
            var newOrient: [DatedFloat4] = []
            var readTime: Date?
            
            let numFloats = 16 // 64 bytes
            let tickerStart = 0 // 0 byte offset
            let imuMotionDataStart = 2 // 8 byte offset
            let emgStart = 11 // 44 byte offset
            let orientStart = 12 // After emg, 48 byte offset
            if floatArray.count % numFloats != 0 {
                log.error("[DataFast] INCORRECT READ COUNT")
            }
            for i in 0...floatArray.count {
                if i % numFloats == tickerStart + 1 { // First 2 "floats" bytes are really a uint64_t ticker
                    let ticker = UInt64(floatArray[i-1].bitPattern) | (UInt64(floatArray[i].bitPattern) << UInt32.bitWidth)
                    readTime = Date.fromFitnetTick(ticker)
                } else if i % numFloats == imuMotionDataStart + 2 { // First 3 floats are planar
                    planar.append(DatedFloat3(readTime: readTime!, read: SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i])))
                } else if i % numFloats == imuMotionDataStart + 5 { // Second 3 floats are gyro
                    gyro.append(DatedFloat3(readTime: readTime!, read: SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i])))
                } else if i % numFloats == imuMotionDataStart + 8 { // Third 3 floats are mag
                    mag.append(DatedFloat3(readTime: readTime!, read: SIMD3<Float>(floatArray[i-2], floatArray[i-1], floatArray[i])))
                } else if i % numFloats == emgStart { // This is EMG
                    newEmg.append(DatedFloat(readTime: readTime!, read: floatArray[i]))
                } else if i % numFloats == orientStart + 3 { // Last 4 floats are orientation quaternion
                    newOrient.append(DatedFloat4(readTime: readTime!, read: SIMD4<Float>(floatArray[i-3], floatArray[i-2], floatArray[i-1], floatArray[i])))
                }
            }
            self.planar = DatedFloat3List(planar)
            self.gyro = DatedFloat3List(gyro)
            self.mag = DatedFloat3List(mag)
            self.emg = DatedFloatList(newEmg)
            self.orient = DatedFloat4List(newOrient)
        }
        
        public override func writeValueAsync(data: Data, timeout: Duration) async -> BleWriteResult {
            log.error("[\(self.name)] Cannot write to read-only char")
            return .invalid
        }
        
    }
}

//
//  TestBiodyn.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestBiodyn: PBiodyn {
    typealias TTest = TestTestService
    typealias TDeviceInfo = TestDeviceInformationService
    typealias TSelfTest = TestSelfTestService
    typealias TIMU = TestIMUService

    var uuid: UUID = UUID()
    var deviceInfoService: TestDeviceInformationService
    var testService: TestTestService
    var selfTestService: TestSelfTestService
    var imuService: TestIMUService

    init(name: String, manuf: String, ver: String) {
        deviceInfoService = TestDeviceInformationService(name, manuf, ver)
        testService = TestTestService()
        selfTestService = TestSelfTestService()
        imuService = TestIMUService()
    }
}

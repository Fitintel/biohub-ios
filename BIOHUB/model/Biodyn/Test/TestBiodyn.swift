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
    typealias TEMG = TestEMGService
    typealias TDataFast = TestDataFastService

    var uuid: UUID = UUID()
    var deviceInfoService: TestDeviceInformationService
    var testService: TestTestService
    var selfTestService: TestSelfTestService
    var imuService: TestIMUService
    var emgService: TestEMGService
    var dfService: TestDataFastService

    init(name: String, manuf: String, ver: String) {
        deviceInfoService = TestDeviceInformationService(name, manuf, ver)
        testService = TestTestService()
        selfTestService = TestSelfTestService()
        let imus = TestIMUService()
        imuService = imus
        let emgs = TestEMGService()
        emgService = emgs
        dfService = TestDataFastService(emgs, imus)
    }
}

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
    typealias TDeviceInfo = TestDeviceInformationService
    typealias TTest = TestTestService

    var uuid: UUID = UUID()
    var deviceInfoService: TestDeviceInformationService
    var testService: TestTestService = TestTestService()
    
    init(name: String, ver: String) {
        deviceInfoService = TestDeviceInformationService(name, ver)
    }
}

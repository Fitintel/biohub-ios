//
//  TestDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

@Observable
class TestDeviceInformationService: PDeviceInfoService {
    var manufNameStr: String? { get { "FITNET" } }
    var firmwareRevStr: String? { get { "TEST" } }
}

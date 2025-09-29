//
//  TestDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestDeviceInformationService: PDeviceInfoService {
    var manufNameStr: String? = nil
    var firmwareRevStr: String? = nil
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.manufNameStr = "FITNET"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.firmwareRevStr = "0.0.1"
        }
    }
}

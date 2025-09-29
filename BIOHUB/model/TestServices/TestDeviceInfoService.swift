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
    
    init(_ manuf: String, _ ver: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.manufNameStr = manuf
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.firmwareRevStr = ver
        }
    }
}

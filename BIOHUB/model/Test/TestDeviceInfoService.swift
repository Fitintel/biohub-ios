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
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.4, 0.6, 0.7, 0.9, 1, 1.4, 2].randomElement()!) {
            self.manufNameStr = manuf
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2, 0.4, 0.5, 0.8, 1.2, 1.4, 1.9].randomElement()!) {
            self.firmwareRevStr = ver
        }
    }
}

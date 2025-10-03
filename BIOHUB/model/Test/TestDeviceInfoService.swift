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
    var modelNumStr: String? = nil
    var serialNumStr: String? = nil
    var harwareRevStr: String? = nil
    var systemIdStr: String? = nil
    var manufNameStr: String? = nil
    var firmwareRevStr: String? = nil
    
    init(_ name: String, _ manuf: String, _ ver: String) {
        var rng = SystemRandomNumberGenerator()
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.4, 0.6, 0.7, 0.9, 1, 1.4, 2].randomElement()!) {
            self.manufNameStr = manuf
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2, 0.4, 0.5, 0.8, 1.2, 1.4, 1.9].randomElement()!) {
            self.firmwareRevStr = ver
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2, 0.4, 0.5, 0.8, 1.2, 1.4, 1.9].randomElement()!) {
            self.harwareRevStr = "dummy"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2, 0.4, 0.5, 0.8, 1.2, 1.4, 1.9].randomElement()!) {
            self.modelNumStr = "\(rng.next())"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + [0.1, 0.2, 0.4, 0.5, 0.8, 1.2, 1.4, 1.9].randomElement()!) {
            self.systemIdStr = name
        }
    }
}

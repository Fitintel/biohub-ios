//
//  TestDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation
import Foundation

@Observable
class TestDeviceInformationService: PDeviceInfoService, TestWithDelays {
    var modelNumStr: String? = nil
    var serialNumStr: String? = nil
    var harwareRevStr: String? = nil
    var systemIdStr: String? = nil
    var manufNameStr: String? = nil
    var firmwareRevStr: String? = nil
    
    init(_ name: String, _ manuf: String, _ ver: String) {
        var rng = SystemRandomNumberGenerator()
        doImmediately { self.manufNameStr = manuf }
        doSoon { self.firmwareRevStr = ver }
        doSoon { self.harwareRevStr = "dummy" }
        doEventually { self.modelNumStr = "\(rng.next())" }
        doAtSomePoint { self.systemIdStr = name }
    }
}

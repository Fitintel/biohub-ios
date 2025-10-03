//
//  PDeviceInfoService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import Observation

public protocol PDeviceInfoService: Observable {
    var manufNameStr: String? { get }
    var modelNumStr: String? { get }
    var serialNumStr: String? { get }
    var harwareRevStr: String? { get }
    var firmwareRevStr: String? { get }
    var systemIdStr: String? { get }
}

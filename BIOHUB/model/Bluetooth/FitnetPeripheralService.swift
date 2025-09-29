//
//  FitnetPeripheralService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth

// A FITNET peripheral service
public protocol FitnetPeripheralService: ObservableObject {
    
    // Returns whether this service was matched
    func loadService(_ service: CBService) -> Bool
    
    // Returns whether this characteristic was mathed
    func loadCharacteristic(_ char: CBCharacteristic) -> Bool
    
    // Returns whether this characteristic read was matched
    func notifyRead(_ char: CBCharacteristic) -> Bool
    
}

extension FitnetPeripheralService {
    // Convenience method for service loading
    static func loadService(tag: String, service: CBService, uuid: CBUUID, setFound: () -> Void) -> Bool {
        if service.uuid == uuid {
            log.info("[\(tag)] Found service UUID")
            setFound()
            return true
        }
        return false
    }
    
    // Convenience method for characteristic loading
    static func loadCharacteristic(tag: String,
                                   checkedChar: CBCharacteristic,
                                   foundService: Bool,
                                   chars: [CBUUID],
                                   setFound: (CBCharacteristic) -> Void) -> Bool {
        // Check if service found
        if !foundService {
            log.error("[\(tag)] Has not found service UUID yet.")
            return false
        }
        
        // Check for characteristics
        for char in chars {
            if char == checkedChar.uuid {
                setFound(checkedChar)
                return true
            }
        }
        
        return false
    }
    
    func notifyRead(_ char: CBCharacteristic) -> Bool {
        return false
    }
}

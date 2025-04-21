//
//  FitnetPeripheralService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth

// A FITNET peripheral service
protocol FitnetPeripheralService: ObservableObject {
    
    // Returns whether this service was matched
    func loadService(_ service: CBService) -> Bool
    
    // Returns whether this characteristic was mathed
    func loadCharacteristic(_ char: CBCharacteristic) -> Bool
    
    // Returns whether this characteristic read was matched
    func notifyRead(_ char: CBCharacteristic) -> Bool
    
}

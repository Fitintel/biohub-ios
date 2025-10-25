//
//  FitnetPeripheralService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-21.
//

import CoreBluetooth
import Observation


// A FITNET peripheral service
public class FitnetBLEService: ObservableObject {
    
    var name: String
    var uuid: CBUUID
    var characteristics: [FitnetBLEChar] { get { Array(characteristicsMap.values) } }
    var foundService: Bool = false
    var characteristicsMap = Dictionary<CBUUID, FitnetBLEChar>();
    var peripheral: CBPeripheral
    
    init(_ peripheral: CBPeripheral,
         name: String,
         uuid: CBUUID,
         characteristics: [FitnetBLEChar]) {
        self.peripheral = peripheral
        self.name = name
        self.uuid = uuid
        for char in characteristics {
            characteristicsMap.updateValue(char, forKey: char.uuid)
        }
    }
    
    // Called when this service is loaded. Default behaviour is do nothing
    open func onLoaded() {}
    
    public final func notifyRead(_ char: CBCharacteristic) -> Bool {
        var wasRead = false
        if self.characteristicsMap[char.uuid] != nil {
            let c = characteristicsMap[char.uuid]!
            guard let data = char.value else {
                log.error("[\(self.name)] notified of read, but had no data!")
                return false
            }
            c.onReadInternal(data)
            wasRead = true
        }
        return wasRead
    }
    
    public final func notifyWrite(_ char: CBCharacteristic) -> Bool {
        var wasWritten = false
        if self.characteristicsMap[char.uuid] != nil {
            characteristicsMap[char.uuid]!.onWriteInternal()
            wasWritten = true
        }
        return wasWritten
    }

    public final func loadService(_ service: CBService) -> Bool {
        if service.uuid == uuid {
            foundService = true
            onLoaded()
            log.info("[\(self.name)] Loaded")
            return true
        }
        return false
    }
    
    public final func loadCharacteristic(_ char: CBCharacteristic) -> Bool {
        // Check if service found
        if !foundService {
            log.error("[\(self.name)] Has not found service UUID yet")
            return false
        }
        
        // Load er? i hardly know er!
        if self.characteristicsMap[char.uuid] != nil {
            let c = characteristicsMap[char.uuid]!
            c.loaded = true
            c.cbChar = char
            c.onLoaded()
            return true
        }
        log.error("[\(self.name)] Could not find \(char.uuid) in owned chars: \(self.characteristicsMap.keys)")
        return false
    }

}

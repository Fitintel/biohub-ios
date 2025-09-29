//
//  ContentView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-04-03.
//

import SwiftUI
import CoreBluetooth
import OSLog

let log = Logger()

struct MainView: View {
    
    @State var peripheralsManager = PeripheralsManager(biodynDiscovery: TestPeripheralsDiscovery())
    @State var fitnet: Fitnet<TestBiodyn, TestPeripheralsDiscovery>? = nil

    var body: some View {
        if fitnet != nil {
            NetView(fitnet: $fitnet)
        } else {
            if peripheralsManager.hasBiodyns {
                PeripheralsView(fitnet: $fitnet, peripheralsManager: peripheralsManager)
            } else if !self.peripheralsManager.biodynDiscovery.isDiscoverySupported {
                Text(self.peripheralsManager.biodynDiscovery.getDiscoveryError()).multilineTextAlignment(.center)
            } else {
                VStack {
                    Text("Scanning for FITNET devices")
                    ProgressView()
                }
            }
        }
    }
}



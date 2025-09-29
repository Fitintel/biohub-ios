//
//  NetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import SwiftUI

struct NetView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {

    @Binding var fitnet: Fitnet<B, BD>?
    
    var body: some View {
        VStack {
            Button(action: {
                fitnet?.peripheralsManager.biodynDiscovery.startDiscovery()
                fitnet = nil
            }) {
                Text("Recreate Net")
            }
            Text("\(fitnet?.biodyns.count ?? 0) item(s) in net")
        }
    }

}

//
//  3DNetView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-28.
//

import SwiftUI
import Foundation

struct Net3DView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var app: AppState<B, BD>
    @Bindable var net: Net3DMode<B, BD>
    
    public var body: some View {
        VStack {
            Text("3D Net View")
            List($app.fitnet.biodyns, id: \.uuid.uuidString) { $biodyn in
                VStack {
                    Text("Biodyn \(biodyn.deviceInfoService.systemIdStr ?? "?")")
                    BiodynView3D<B, BD>(biodyn: $biodyn)
                }
            }
        }
    }
    
}

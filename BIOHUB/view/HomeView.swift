//
//  HomeView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-09-28.
//

import SwiftUI

struct HomeView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    @Bindable var app: AppState<B, BD>

    var body: some View {
        VStack {
            if !app.isLoggedIn {
                Text("Warning: You are not signed in, some features may not work.")
                    .multilineTextAlignment(.center)
                Spacer()
                Button(action: {
                    app.home.path.append(.signIn)
                }) {
                    Text("Sign In")
                }
            }
            Spacer()
        }
        .navigationTitle("Home")
    }
    
}

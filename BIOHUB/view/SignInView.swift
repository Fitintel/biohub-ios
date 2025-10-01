//
//  LoginView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-01.
//

import SwiftUI

struct SignInView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    @Bindable var app: AppState<B, BD>
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            TextField(text: $username) {
                Text("Username")
            }
            TextField(text: $password) {
                Text("Password")
            }
            Button(action: {
                // TODO: Actually sign in
                app.isLoggedIn = true
                let _ = app.home.path.popLast()
            }) {
                Text("Sign In")
            }
        }
        .padding()
        .navigationTitle("Sign Into FITNET")
    }
}

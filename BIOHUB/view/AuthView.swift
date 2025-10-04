//
//  LoginView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-01.
//

import SwiftUI

struct AuthView<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    @EnvironmentObject var authService: AuthService
    @Bindable var app: AppState<B, BD>
    @State var username: String = ""
    @State var password: String = ""
    @State var login: Bool = true

    var body: some View {
        VStack {
            HStack {
                Text(login ? "Don't have an account?" : "Already have an account?")
                Spacer()
                Button(action: {
                    login = !login
                }) {
                    Text(login ? "Sign Up" : "Log In")
                }
            }
            Divider()
            Text("\(login ? "Log In" : "Sign Up") With Email")
                .font(.subheadline)
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
                Text(login ? "Log In" : "Sign Up")
            }
            Divider()
            SignInWithAppleButtonView(login: $login)
            Spacer()
        }
        .padding()
        .navigationTitle("\(login ? "Log In to" : "Sign Up for") FITNET")
    }
}

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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var login: Bool = true
    @State private var isLoggingIn: Bool = false
    @State private var loginError: String? = nil

    var body: some View {
        VStack {
            HStack {
                Text(login ? "Don't have an account?" : "Already have an account?")
                Spacer()
                Button(action: {
                    login = !login
                }) {
                    Text(login ? "Sign Up" : "Log In")
                }.disabled(isLoggingIn)
            }
            Spacer()
            Divider()
            Text("\(login ? "Log In" : "Sign Up") With Email")
                .font(.subheadline)
            TextField(text: $email) {
                Text("Email")
            }.disabled(isLoggingIn)
            SecureField(text: $password) {
                Text("Password")
            }.disabled(isLoggingIn)
            Button(login ? "Log In" : "Sign Up") {
                Task { await authenticateEmailPassword() }
            }.disabled(isLoggingIn)
            if loginError != nil {
                Text(loginError!).multilineTextAlignment(.center)
            }
            if isLoggingIn {
                ProgressView()
            }
            Divider()
            Spacer()
            //Divider()
            // Sign in with apple is only available when paying ...
            // SignInWithAppleButtonView(login: $login, isLoggingIn: $isLoggingIn)
        }
        .padding()
        .navigationTitle("\(login ? "Log In to" : "Sign Up for") FITNET")
    }
    
    private func authenticateEmailPassword() async {
        isLoggingIn = true
        do {
            if login {
                try await authService.signIn(email: email, password: password)
            } else {
                try await authService.signUp(email: email, password: password)
            }
        } catch {
            log.error("[AuthView] Failed to sign in/up user: \(error.localizedDescription)")
            loginError = error.localizedDescription
            isLoggingIn = false
            return
        }
        let _ = app.home.path.popLast()
        app.isLoggedIn = true
    }
}

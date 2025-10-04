//
//  SignInWithAppleButton.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-03.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Observation

struct SignInWithAppleButtonView: View {
    @EnvironmentObject var auth: AuthService
    @Binding var login: Bool
    @Binding var isLoggingIn: Bool
    @State private var currentNonce: String?
    
    var body: some View {
        // See https://www.createwithswift.com/sign-in-with-apple-on-a-swiftui-application/
        SignInWithAppleButton(login ? .signIn : .signUp) { request in
            request.requestedScopes = [.fullName, .email]
            isLoggingIn = true
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    log.info("[SignInWithApple] \(userCredential.user), \(userCredential.fullName?.formatted() ?? "") \(userCredential.email ?? "")")
                }
            case .failure(let err):
                print("[SignInWithApple] Could not authenticate: \(err.localizedDescription)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .disabled(isLoggingIn)
        .frame(maxWidth: 375)
        .frame(height: 44)
    }
}

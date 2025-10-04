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
    @State private var currentNonce: String?
    
    var body: some View {
        // See https://www.createwithswift.com/sign-in-with-apple-on-a-swiftui-application/
        SignInWithAppleButton(login ? .signIn : .signUp) { request in
        } onCompletion: { result in
        }
            .signInWithAppleButtonStyle(.black)
    }
    
}

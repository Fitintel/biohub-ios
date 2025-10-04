//
//  AuthService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-03.
//

import FirebaseAuth
import Observation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var user: User? = Auth.auth().currentUser
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    
    // Email/Password
    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func sendPasswordReset(to email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
}

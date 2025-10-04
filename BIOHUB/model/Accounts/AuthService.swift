//
//  AuthService.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-03.
//

import FirebaseAuth
import FirebaseFirestore
import Observation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var currentUser: FitnetUser? = nil
    @Published private var userSession: User? = Auth.auth().currentUser
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
        }
    }
    
    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    
    // Email/Password
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user
        if self.userSession == nil {
            log.error("[AuthService] Logged in but had no user")
            return
        }
        let fitnetUser = FitnetUser(uid: userSession!.uid, email: email)
        let encodeUser = try Firestore.Encoder().encode(fitnetUser)
        try await Firestore.firestore().collection("Users").document(userSession!.uid).setData(encodeUser)
        await fetchUser()
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        await fetchUser()
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
    
    func fetchUser() async {
        guard let uid = userSession?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("Users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: FitnetUser.self)
    }
}

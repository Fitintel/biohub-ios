//
//  User.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

// FIRESTORE DATABASE REPRESENTATION OF USER
public struct FitnetUser: Encodable, Decodable {
    public let uid: String
    public let email: String
}

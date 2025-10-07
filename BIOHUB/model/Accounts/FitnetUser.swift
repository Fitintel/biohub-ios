//
//  User.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-04.
//

import Foundation
import FirebaseFirestore

// FIRESTORE DATABASE REPRESENTATION OF USER
public struct FitnetUser: Encodable, Decodable {
    public let uid: String
    public let email: String
    
    func uploadIMUData(_ data: Dictionary<String, IMUDataStream>) async throws {
        let uploadTime = Date.now
        let encodeData = try Firestore.Encoder().encode(data)
        try await Firestore.firestore().collection("UserIMU").document(uid).setData(encodeData)
        log.info("[FitnetUser] Uploaded IMU data")
    }
}

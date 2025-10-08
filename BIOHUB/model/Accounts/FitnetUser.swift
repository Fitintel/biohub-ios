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
        let encodeData = try Firestore.Encoder().encode(IMURecord(data: data, time: uploadTime))
        try await Firestore.firestore()
            .collection("UserIMU")
            .document(uid)
            .collection("Sessions")
            .document(uploadTime.ISO8601Format())
            .setData(encodeData)
        log.info("[FitnetUser] Uploaded IMU data")
    }
}

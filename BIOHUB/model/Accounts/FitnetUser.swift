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
    private static let TAG: String = "FitnetUser"
    
    public let uid: String
    public let email: String
    
    func uploadAllData(_ data: Dictionary<String, FullDataStream>) async throws {
        let uploadTime = Date.now
        let encodeData = try Firestore.Encoder().encode(FullDataRecord(data: data, time: uploadTime))
        try await Firestore.firestore()
            .collection("UserData")
            .document(uid)
            .collection("Sessions")
            .document(uploadTime.ISO8601Format())
            .setData(encodeData)
        log.info("[\(Self.TAG)] Uploaded full data")
    }
    
    func uploadTrainingData(label: String, data: Dictionary<String, FullDataStream>) async throws {
        let uploadTime = Date.now
        let encodeData = try Firestore.Encoder().encode(TrainingDataRecord(data: TrainingDataStream(data: data, label: label), time: uploadTime))
        try await Firestore.firestore()
            .collection("TrainingData")
            .document(uid)
            .collection("Sessions")
            .document(uploadTime.ISO8601Format())
            .setData(encodeData)
        log.info("[\(Self.TAG)] Uploaded training data")
    }
}

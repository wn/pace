//
//  Pace+Firebase.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Pace {
    /// Adds this pace to Firestore.
    func addToFirestore(to firestore: Firestore, callback: @escaping (Error?) -> Void) {
        let paces = firestore.collection("paces")
        paces.addDocument(data: toFirestoreDoc()) { callback($0) }
    }

    /// Converts to a firestore-compatible data structure
    private func toFirestoreDoc() -> [String: Any] {
        return [
            "user_id": String(runner.userId),
            "checkpoints": checkpoints.map { $0.time }
        ]
    }
}

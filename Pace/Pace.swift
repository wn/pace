//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Pace {
    private let runner: User
    private var checkpoints: [CheckPoint]

    init(runner: User, checkpoints: [CheckPoint]) {
        self.runner = runner
        self.checkpoints = checkpoints
    }
    
    /// Adds this pace to Firestore.
    func add(to firestore: Firestore, callback: @escaping (Error?) -> Void) {
        let paces = firestore.collection("paces")
        paces.addDocument(data: toFirestoreDoc()) { callback($0) }
    }

    /// Converts to a firestore-compatible data structure
    private func toFirestoreDoc() -> Dictionary<String, Any> {
        return [
            "user_id": String(runner.id),
            "checkpoints": checkpoints.map {
                Timestamp(date: $0.time)
            }
        ]
    }
}

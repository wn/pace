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

    /// Constructs a Pace with the given runner and an array of normalized CheckPoints.
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
            "checkpoints": checkpoints.map { $0.time }
        ]
    }

    /// Normalizes an array of CheckPoints based on the checkPoints array of this Pace.
    /// - Precondition: the given runner record does not deviate from this Pace.
    /// - Parameter runnerRecords: the array of CheckPoints to be normalized.
    /// - Returns: an array of normalized CheckPoints.
    func normalize(_ runnerRecords: [CheckPoint]) -> [CheckPoint] {
        var normalizedCheckPoints = [CheckPoint]()
        for basePoint in self.checkPoints {
            let normalizedPoint = basePoint.extractNormalizedPoint(from: runnerRecords)
            normalizedCheckPoints.append(normalizedPoint)
        }
        return normalizedCheckPoints
    }
}

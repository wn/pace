//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

class Pace: Object {
    @objc dynamic var id: String?
    @objc dynamic var runner: User?
}

/*
class Pace: FirestoreCodable {
    var docId: String?
    let runner: User
    var checkpoints: [CheckPoint]

    init(runner: User, checkpoints: [CheckPoint]) {
        self.runner = runner
        self.checkpoints = []
    }

    // Only load the metadata (without the timings)
    required init?(docId: String, data: [String: Any]) {
        guard
            let runnerId = data[FireDB.Pace.userId] as? String,
            let runnerData = data[FireDB.Pace.userData] as? [String: Any] else {
            return nil
        }
        guard let runner = User(docId: runnerId, data: runnerData) else {
            return nil
        }
        self.runner = runner
        self.checkpoints = []

    }

    // Checkpoints are loaded into the Pace separately from instantiation
    func loadCheckpoints(with route: Route, timings: [Double]) {
        guard route.locations.count == timings.count else {
            // Stored timings should have a one-to-one mapping to each location
            return
        }
        for (index, location) in route.locations.enumerated() {
            let checkpoint = CheckPoint(location: location,
                                       time: timings[index],
                                       actualDistance: 0,
                                       routeDistance: 0)
            self.checkpoints.append(checkpoint)
        }
    }

    /// Adds the next checkpoint to the pace
    func addNextCheckpoint(_ checkpoint: CheckPoint) {
        checkpoints.append(checkpoint)
    }

    /// Normalizes an array of CheckPoints based on the checkPoints array of this Pace.
    /// - Precondition: the given runner record does not deviate from this Pace.
    /// - Parameter runnerRecords: the array of CheckPoints to be normalized.
    /// - Returns: an array of normalized CheckPoints.
    func normalize(_ runnerRecords: [CheckPoint]) -> [CheckPoint] {
        var normalizedCheckPoints = [CheckPoint]()
        for basePoint in checkpoints {
            let normalizedPoint = basePoint.extractNormalizedPoint(from: runnerRecords)
            normalizedCheckPoints.append(normalizedPoint)
        }
        return normalizedCheckPoints
    }
}

extension Pace {
    func toFirestoreDoc() -> [String: Any] {
        return [
            FireDB.Pace.timings: checkpoints.map { $0.time },
            FireDB.Pace.distances: checkpoints.compactMap { $0.routeDistance },
            FireDB.Pace.userId: runner.docId ?? ""
        ]
    }
}
 */


//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class Pace: FirestoreCodable {
    private let runner: User
    private var checkpoints: [CheckPoint]

    init(route: Route, runner: User) {
        self.route = route
        self.runner = runner
        self.checkpoints = []
    }

    // Only load the metadata (without the timings)
    init?(route: Route, docId: String, document: [String: Any]) {
        guard let runnerId = document[FireDB.Pace.userId] as? String else {
            return nil
        }
        self.route = route
        self.runner = User(userId: runnerId)
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

    required convenience init?(dictionary: [String: Any]) {
        guard
            let runnerId = dictionary["user_id"] as? Int,
            let times = dictionary["checkpoint_times"] as? [Double],
            let distances = dictionary["route_distances"] as? [Double]
            else {
                return nil
        }
        let checkpoints = zip(times, distances).map { time, dist in CheckPoint(time: time, routeDistance: dist) }
        self.init(runner: User(id: runnerId, name: ""), checkpoints: checkpoints)
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
    static let collectionID = CollectionNames.paces

    func toFirestoreDoc() -> [String: Any] {
        return [
            "user_id": String(runner.id),
            "checkpoint_times": checkpoints.map { $0.time },
            "route_distances": checkpoints.compactMap { $0.routeDistance }
        ]
    }
}

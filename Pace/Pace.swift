//
//  Pace.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Pace: FirestoreCodable {
    private let runner: User
    private var checkpoints: [CheckPoint]

    init(runner: User, checkpoints: [CheckPoint]) {
        self.runner = runner
        self.checkpoints = checkpoints
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

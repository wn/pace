//
//  Route.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Route {
    private let creator: User
    let name: String
    private var paces: [Pace]
    private var checkpoints: [GeoPoint]

    init(creator: User, name: String, paces: [Pace], locations: [GeoPoint]) {
        self.creator = creator
        self.name = name
        self.paces = paces
        self.checkpoints = locations
    }

    init?(dictionary: Dictionary<String, Any>) {
        guard
            let name = dictionary["name"],
            let locations = dictionary["checkpoints"] else {
                return nil
        }
        print("constructing: \(name), \(locations)")
        self.creator = User(id: 0)
        self.name = name as! String
        self.paces = []
        self.checkpoints = locations as! [GeoPoint]
    }

    /// Retrieves all `Route`s from the Firestore database.
    static func all(firestore: Firestore, callback: @escaping ([Route]?) -> Void) {
        let routesRef = firestore.collection("routes")
        routesRef.getDocuments { querySnapshot, err in
            guard err == nil else {
                print("Error acquiring documents")
                return
            }
            let routes = querySnapshot?.documents
                .compactMap { Route(dictionary: $0.data()) }
            callback(routes)
        }
    }

    /// Constructs a Route for the first time, when a runner just finished the
    /// first pace for this route.
    convenience init(runner: User, runnerRecords: [CheckPoint]) {
        let initialPace = Pace(runner: runner, checkPoints: Route.initialNormalize(runnerRecords))
        self.init(creator: runner, paces: [initialPace])
    }

    /// Normalize an array of CheckPoints based on the pre-defined distance interval
    /// pre-condition: the runner records are arranged with increasing routeDistance
    static private func initialNormalize(_ runnerRecords: [CheckPoint]) -> [CheckPoint] {
        guard runnerRecords.count >= 2 else {
            // empty or only has one point recorded
            return runnerRecords
        }
        var currentDistance: Double = 0
        var leftPointIndex = 0
        var rightPointIndex = 1
        var normalizedCheckPoints = [CheckPoint]()
        // slide the window to find interval which fits the current distance
        while rightPointIndex < runnerRecords.endIndex {
            let leftPoint = runnerRecords[leftPointIndex]
            let rightPoint = runnerRecords[rightPointIndex]
            if currentDistance > rightPoint.routeDistance {
                // impossible to find more points in the current interval, move the window
                leftPointIndex += 1
                rightPointIndex += 1
            }
            if currentDistance >= leftPoint.routeDistance && currentDistance <= rightPoint.routeDistance {
                // current distance falls inside the current interval
                let normalizedPoint = CheckPoint.interpolate(with: currentDistance, between: leftPoint, and: rightPoint, on: nil)
                normalizedCheckPoints.append(normalizedPoint)
                currentDistance += Constants.checkPointDistanceInterval
            }
        }
        return normalizedCheckPoints
    }
}

//
//  Route.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Route: FirestoreCodable {
    let creator: User
    var docId: String?
    let name: String
    var locations: [CLLocation]
    var paces: [Pace]

    /// Constructs a Route with the given creator and array of Paces.
    init(docId: String?, creator: User, name: String, paces: [Pace]) {
        self.docId = docId
        self.creator = creator
        self.name = name
        self.locations = []
        self.paces = paces
    }

    required init?(docId: String, data: [String: Any]) {
        guard
            let creatorId = data[FireDB.Route.creatorId] as? String,
            let userData = data[FireDB.Route.creatorData] as? [String: Any],
            let name = data[FireDB.Route.name] as? String,
            let locations = data[FireDB.Route.checkpoints] as? [GeoPoint] else {
                return nil
        }
        guard let creator = User(docId: creatorId, data: userData) else {
            return nil
        }
        self.creator = creator
        self.docId = docId
        self.name = name
        self.paces = []
        self.locations = locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
    }

    /// Constructs a Route with the given runner and an array of unnormalized CheckPoints representing
    /// the running record from the runner.
    /// To be used for creating Route for the first time when a runner just finished the first Pace for a Route.
    convenience init(runner: User, runnerRecords: [CheckPoint]) {
        let initialPace = Pace(runner: runner, checkpoints: Route.initialNormalize(runnerRecords))
        self.init(docId: nil, creator: runner, name: "blabla", paces: [initialPace])
    }

    /// Normalizes an array of CheckPoints based on the pre-defined distance interval.
    /// - Precondition: The runner records are arranged by increasing routeDistance.
    /// - Parameter runnerRecords: the array of CheckPoints to be normalized.
    /// - Returns: an array of normalized CheckPoints.
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
                let normalizedPoint = CheckPoint.interpolate(with: currentDistance, between: leftPoint,
                                                             and: rightPoint, on: nil)
                normalizedCheckPoints.append(normalizedPoint)
                currentDistance += Constants.checkPointDistanceInterval
            }
        }
        return normalizedCheckPoints
    }
}

extension Route {
    func toFirestoreDoc() -> [String: Any] {
        return [
            FireDB.Route.name: name,
            FireDB.Route.checkpoints: locations,
            FireDB.Route.creatorId: creator.docId ?? ""
        ]
    }
}

//
//  Route.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Route: Object {
    @objc dynamic var creator: User?
    @objc dynamic var name: String = ""
    var creatorRun: Run?
    var paces = List<Run>()

    convenience init(creator: User, name: String, locations: [CLLocation], paces: [Run]) {
        self.init()
        self.creator = creator
        self.name = name
        self.paces = {
            let pacesList = List<Run>()
            pacesList.append(objectsIn: paces)
            return pacesList
        }()
    }

    /// Constructs a Route with the given runner and an array of unnormalized CheckPoints representing
    /// the running record from the runner.
    /// To be used for creating Route for the first time when a runner just finished the first Pace for a Route.
    convenience init(runner: User, runnerRecords: [CheckPoint]) {
        let initialPace = Run(runner: runner, checkpoints: Route.initialNormalize(runnerRecords))
        self.init(creator: runner, name: "blabla", locations: initialPace.locations, paces: [initialPace])
    }

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

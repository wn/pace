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
    @objc dynamic var thumbnailData: Data?
    var thumbnail: UIImage? {
        guard let thumbnailData = thumbnailData else {
            return UIImage(named: "run.jpeg")
        }
        return UIImage(data: thumbnailData)
    }
    var creatorRun: Run?
    var paces = List<Run>()

    /// Constructs a route given the runner, name, the first (creator) run and collection to paces.
    /// - Precondition: `creatorRun` must be within `paces`.
    /// - Parameters:
    ///   - creator: The creator of the route.
    ///   - name: The name of the route.
    ///   - creatorRun: The first run in the route (made by creator).
    convenience init(creator: User, name: String, thumbnail: Data? = nil, creatorRun: Run, paces: List<Run>) {
        assert(paces.contains(creatorRun))
        self.init()
        self.creator = creator
        self.name = name
        self.creatorRun = creatorRun
        self.paces = paces
        self.thumbnailData = thumbnail
    }

    /// Constructs a route given the runner, name and the first (creator) run.
    /// - Parameters:
    ///   - creator: The creator of the route.
    ///   - name: The name of the route.
    ///   - creatorRun: The first run in the route (made by creator).
    convenience init(creator: User, name: String, thumbnail: Data? = nil,creatorRun: Run) {
        self.init(creator: creator, name: name, thumbnail: thumbnail, creatorRun: creatorRun, paces: List(creatorRun))
    }

    /// Constructs a Route with the given runner and an array of pre-normalized checkpoints representing
    /// the running record from the runner.
    /// - Parameters:
    ///   - runner: The runner of these records.
    ///   - runnerRecord: The pre-normalized checkpoints representing the run.
    convenience init(runner: User, runnerRecords: [CheckPoint]) {
        let initialRun = Run(runner: runner, checkpoints: Route.initialNormalize(runnerRecords))
        self.init(creator: runner, name: "blabla", creatorRun: initialRun)
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

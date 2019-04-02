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

class Route: IdentifiableObject {
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

<<<<<<< HEAD
    required init?(data: [String: Any]) {
        guard
            let docId = data[FireDB.primaryKey] as? String,
            let userData = data[FireDB.Route.creatorData] as? [String: Any],
            let name = data[FireDB.Route.name] as? String,
            let locations = data[FireDB.Route.checkpoints] as? [GeoPoint] else {
                return nil
        }
        guard let creator = User(data: userData) else {
            return nil
        }
        self.creator = creator
        self.docId = docId
        self.name = name
        self.paces = []
        self.locations = locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
=======
    /// Constructs a route given the runner, name and the first (creator) run.
    /// - Parameters:
    ///   - creator: The creator of the route.
    ///   - name: The name of the route.
    ///   - creatorRun: The first run in the route (made by creator).
    convenience init(creator: User, name: String, thumbnail: Data? = nil, creatorRun: Run) {
        self.init(creator: creator, name: name, thumbnail: thumbnail, creatorRun: creatorRun, paces: List(creatorRun))
>>>>>>> 101572c87a1970f308c03bc389a297135b06247a
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

    /// Add a new run to this Route.
    /// Only use this method to add a following run, but not a creator run.
    /// - Parameter run: The new run to be added.
    func addNewRun(_ run: Run) {
        // TODO: check for 80% overlap
        paces.append(run)
    }

    /// Generates stats for this route.
    /// - Returns: The RouteStats if all stats can be obtained; nil otherwise.
    func generateStats() -> RouteStats? {
        var runners = Set<User>()
        for run in paces {
            guard let runner = run.runner else {
                fatalError("A run should have a runner.")
            }
            runners.insert(runner)
        }
        return RouteStats(startingLocation: creatorRun?.startingLocation,
                          dateCreated: creatorRun?.dateCreated,
                          totalDistance: creatorRun?.totalDistance,
                          numOfRunners: runners.count,
                          fastestTime: paces.min(ofProperty: "timeSpent"))
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
<<<<<<< HEAD

extension Route {
    func toFirestoreDoc() -> [String: Any] {
        guard
            let startLocation = locations.first,
            let endLocation = locations.last else {
                return [String: Any]()
        }
        return [
            FireDB.Route.startLocation: startLocation,
            FireDB.Route.endLocation: endLocation,
            FireDB.Route.name: name,
            FireDB.Route.checkpoints: locations,
            FireDB.Route.creatorId: creator.docId ?? ""
        ]
    }
}
=======
>>>>>>> 101572c87a1970f308c03bc389a297135b06247a

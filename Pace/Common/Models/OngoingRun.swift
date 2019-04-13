//
//  OngoingRun.swift
//  Pace
//
//  Created by Yuntong Zhang on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

// Represents an ongoing run, should not be persisted so not following realm syntax.
class OngoingRun {
    // runner and points of the ongoing run.
    let runner: User
    var checkpoints: [CheckPoint]
    // the properties of the run that is being followed.
    let paceRun: Run?
    var pacePoints: [CheckPoint]? {
        return paceRun.map { Array($0.checkpoints) }
    }
    // keep track of the checkpoints in paceRun that are covered so far. (only for follow run)
    var coveredPacePoints: Set<CheckPoint>?
    // check this property for the deviating status.
    var isDeviated = false

    /// Constructs an OngoingRun with the given runner, startingLocation and paceRun.
    /// When the OngoingRun is not following any Run, the paceRun is nil (and it's nil by default).
    /// - Parameters:
    ///   - runner: The runner of this OngoingRun.
    ///   - startingLocation: The starting location of this OngoingRun.
    ///   - paceRun: An optional of the Run that the runner is following.
    init(runner: User, startingLocation: CLLocation, paceRun: Run? = nil) {
        self.runner = runner
        let startingPoint = CheckPoint(location: startingLocation, time: 0, actualDistance: 0, routeDistance: 0)
        self.checkpoints = [startingPoint]
        self.paceRun = paceRun
        self.coveredPacePoints = paceRun.map { _ in Set<CheckPoint>() }
        markAsCovered(paceRun?.checkpoints.first)
    }

    /// Adds a new location to the ongoing run.
    /// - Parameters:
    ///   - location: The location to be added.
    ///   - time: The time when the location should be added.
    func addNewLocation(_ location: CLLocation, atTime time: Double) {
        guard let lastPoint = checkpoints.last, let lastLocation = lastPoint.location else {
            fatalError("There should already be exisiting location in this ongoing run.")
        }
        let distanceApart = location.distance(from: lastLocation)
        guard distanceApart > 0 else {
            // make sure adjacent points have different locations to avoid NaN issue in normalization
            return
        }
        // caliberate the actual distance
        let newActualDistance = lastPoint.actualDistance + distanceApart
        // handle new run case
        guard paceRun != nil else {
            let newPoint = CheckPoint(location: location,
                                      time: time,
                                      actualDistance: newActualDistance,
                                      routeDistance: newActualDistance)
            checkpoints.append(newPoint)
            return
        }
        // handle follow run case
        // update deviation status and route distance
        var newRouteDistance: Double
        if let furthestPassedPoint = getLastCheckpointPassed(with: location) { // not deviating
            isDeviated = false
            newRouteDistance = furthestPassedPoint.routeDistance
        } else { // deviating
            isDeviated = true
            newRouteDistance = lastPoint.routeDistance
        }
        let newPoint = CheckPoint(location: location, time: time, actualDistance: newActualDistance, routeDistance: newRouteDistance)
        checkpoints.append(newPoint)
    }

    /// Returns the most recent pacing stats.
    /// - Precondition: This is a follow run and this run is not deviating.
    /// - Returns: The most recent pacing stats; nil if the run is a new run or the run is deviating.
    func getPacingStats() -> PacingStats? {
        guard let pacer = paceRun?.runner, let pacePoints = pacePoints, !isDeviated else {
            return nil
        }
        guard let lastTravelledPoint = checkpoints.last, let lastTravelledLocation = lastTravelledPoint.location else {
            fatalError("There should be existing points travelled.")
        }
        // interpolate from the most recent pace point and its next point
        guard let lastPassedPointIndex = pacePoints
            .firstIndex(where: { $0.routeDistance == lastTravelledPoint.routeDistance }) else {
            fatalError("Should be able to find a point with same routeDistance.")
        }
        let pastPacePoint = pacePoints[lastPassedPointIndex]
        let futurePacePoint = pacePoints[lastPassedPointIndex + 1]
        guard let pastPaceLocation = pastPacePoint.location else {
            fatalError("The point should have an associated location.")
        }
        let currentDistance = pastPacePoint.routeDistance + lastTravelledLocation.distance(from: pastPaceLocation)
        let interpolatedPoint = CheckPoint.interpolate(with: currentDistance,
                                                       between: pastPacePoint, and: futurePacePoint,
                                                       on: lastTravelledLocation)
        let timeDifference = interpolatedPoint.time - lastTravelledPoint.time
        return PacingStats(pacer: pacer, timeDifference: timeDifference)
    }

    /// Checks whether this OngoingRun can be classified as a run in the Route followed.
    /// - Precondition: This OngoingRun is a follow run.
    /// - Returns: true if this OngoingRun can be classified as a valid follow run.
    func classifiedAsFollow() -> Bool {
        guard let pacePoints = pacePoints, let coveredPacePoints = coveredPacePoints else {
            fatalError("This OngoingRun should be a follow run.")
        }
        let coveredPercentage = Double(coveredPacePoints.count) / Double(pacePoints.count)
        return coveredPercentage >= Constants.sameRoutePercentageOverlapThreshold
    }

    /// Checks whether this OngoingRun is a follow run.
    /// - Returns: true if the OngoingRun is a follow run.
    func isFollowRun() -> Bool {
        return paceRun != nil
    }

    /// Converts this OngoingRun to a Run.
    /// - Precondition: (1) This OngoingRun is a follow run, and;
    ///                 (2) A certain amount of checkpoints in the paceRun have been covered.
    /// - Returns: The completed and normalized Run.
    func toRun() -> Run {
        guard let paceRun = paceRun else {
            fatalError("This OngoingRun should be a follow run.")
        }
        guard classifiedAsFollow() else {
            fatalError("This OngoingRun should be classified as a valid follow run to the Route followed.")
        }
        let normalizedPoints = paceRun.normalize(checkpoints)
        return Run(runner: runner, checkpoints: normalizedPoints)
    }

    /// Converts the OngoingRun to a new Route.
    /// - Precondition: (1) This OngoingRun does not follow an existing Route, or;
    ///                 (2) This OngoingRun does not cover the required number of checkpoints in the paceRun.
    /// - Returns: A new Route containing this completed Run.
    func toNewRoute() -> Route {
        guard !isFollowRun() || !classifiedAsFollow() else {
            fatalError("The run should be considered as a new run.")
        }
        return Route(runner: runner, runnerRecords: checkpoints)
    }

    /// Gets the last checkpoint passed with the newly added location.
    /// - Precondition: This is a follow run.
    /// - Parameter newLocation: The newly added location.
    /// - Returns: The checkpoint passed by the new location with the largest routeDistance.
    ///            Nil if the new location does not pass the current point and any point further. (deviating)
    private func getLastCheckpointPassed(with newLocation: CLLocation) -> CheckPoint? {
        guard let pacePoints = pacePoints, let lastTravelledPoint = checkpoints.last else {
            fatalError("This run should be a follow run.")
        }
        var lastPointPassed: CheckPoint?
        // loop through the last passed and yet passted pacePoints
        for baselinePoint in pacePoints where baselinePoint.routeDistance >= lastTravelledPoint.routeDistance {
            guard let baselineLocation = baselinePoint.location else {
                fatalError("Baseline checkpoints should have a location.")
            }
            // TODO: adjust the threshold here for detecting nearby location
            if newLocation.isNear(baselineLocation, within: Constants.checkPointDistanceInterval) {
                markAsCovered(baselinePoint)
                lastPointPassed = baselinePoint
            }
        }
        return lastPointPassed
    }

    /// Marks a checkpoint in the `paceRun` as covered by the `OngoingRun`.
    /// - Precondition: The checkpoint to be marked must be in the paceRun.
    /// - Parameter checkpoint: The checkpoint to be marked as covered.
    private func markAsCovered(_ checkpoint: CheckPoint?) {
        guard let checkpoint = checkpoint, let pacePoints = pacePoints else {
            return
        }
        guard pacePoints.contains(checkpoint) else {
            return
        }
        coveredPacePoints?.insert(checkpoint)
    }
}

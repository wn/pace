//
//  LocatonTime.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation

struct CheckPoint {

    let location: CLLocation
    let time: Double
    private let actualDistance: Double
<<<<<<< HEAD
    // TODO: decide whether to make routeDistance as Optional
    let routeDistance: Double
=======
    let routeDistance: Double?
>>>>>>> cad6c622a22e3f518e4e964aa6d18fbcd8c7a24f

    /// Constructs a CheckPoint with the given Location, time, actualDistance and routeDistance.
    init(location: CLLocation, time: Double, actualDistance: Double, routeDistance: Double) {
        self.location = location
        self.time = time
        self.actualDistance = actualDistance
        self.routeDistance = routeDistance
    }

<<<<<<< HEAD
    /// Extracts a normalized CheckPoint from the given array of sample CheckPoints.
    /// The extracted CheckPoint shares the same routeDistance and location as this CheckPoint.
    /// - Parameter samplePoints: the array of CheckPoints to extract from.
    /// - Returns: a normalized CheckPoint based on this CheckPoint.
    func extractNormalizedPoint(from samplePoints: [CheckPoint]) -> CheckPoint {
        let boundaryPoints = findAdjacentPoints(from: samplePoints)
        guard let leftCp = boundaryPoints.0,
            let rightCp = boundaryPoints.1 else {
                fatalError("The sample points should contain this point in terms of routeDistance.")
        }
        return CheckPoint.interpolate(with: self.routeDistance, between: leftCp, and: rightCp, on: self.location)
    }

    /// Interpolates a new CheckPoint between two CheckPoints, with the given accumulative distance.
    /// - Parameters:
    ///     - currentDistance: the accumulative distance so far.
    ///     - left: the left CheckPoint.
    ///     - right: the right CheckPoint.
    ///     - location: the location of the newly interpolated point; nil if the location of the new
    ///                 point is unknown.
    /// - Returns: the newly interpolated CheckPoint.
    static func interpolate(with currentDistance: Double, between left: CheckPoint,
                            and right: CheckPoint, on location: CLLocation?) -> CheckPoint {
        let interpolateFraction = (currentDistance - left.routeDistance) / (right.routeDistance - left.routeDistance)
        let newTime = left.time + (right.time - left.time) * interpolateFraction
        let newActualDistance = left.actualDistance + (right.actualDistance - left.actualDistance) * interpolateFraction
        if let newLocation = location {
            return CheckPoint(location: newLocation, time: newTime,
                              actualDistance: newActualDistance, routeDistance: currentDistance)
        } else {
            // location is not known, calculate it from interpolation
            let distanceFromLeft = currentDistance - left.routeDistance
            let newLocation = CLLocation.interpolate(with: distanceFromLeft,
                                                     between: left.location,
                                                     and: right.location)
            return CheckPoint(location: newLocation, time: newTime,
                              actualDistance: newActualDistance, routeDistance: currentDistance)
        }
    }

    /// Finds the smaller CheckPoint (by route distance) with largest distance, and the larger CheckPoint
    /// (by route distance) with smallest distance from the given array of CheckPoints.
    /// - Parameter checkPoints: the array of CheckPoints to choose from.
    /// - Returns: a tuple of two Optional CheckPoints. A CheckPoint in the tuple is nil if that bound cannot be found.
    private func findAdjacentPoints(from checkPoints: [CheckPoint]) -> (CheckPoint?, CheckPoint?) {
        var lowerBound = 0
        var upperBound = checkPoints.count - 1
        while upperBound - lowerBound > 1 {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            if checkPoints[midIndex].routeDistance < routeDistance {
                lowerBound = midIndex
            } else {
                upperBound = midIndex
            }
        }
        // check whether the range actually contains this point
        let leftCp = checkPoints[lowerBound]
        let rightCp = checkPoints[upperBound]
        if routeDistance < leftCp.routeDistance {
            return (nil, leftCp)
        } else if routeDistance > rightCp.routeDistance {
            return (rightCp, nil)
        } else {
            return (leftCp, rightCp)
        }
=======
    // TODO: remove/reimplement once we figure out the final shape of the data.
    init(time: Double, routeDistance: Double) {
        self.location = Location(longitude: 0.0, latitude: 0.0)
        self.time = time
        self.routeDistance = routeDistance
        self.actualDistance = 0.0
>>>>>>> cad6c622a22e3f518e4e964aa6d18fbcd8c7a24f
    }
}

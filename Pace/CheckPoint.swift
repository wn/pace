//
//  LocatonTime.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

struct CheckPoint {
    private let location: Location
    let time: Double
    private let actualDistance: Double
    // TODO: decide whether to use optional here
    let routeDistance: Double

    init(location: Location, time: Double, actualDistance: Double, routeDistance: Double) {
        self.location = location
        self.time = time
        self.actualDistance = actualDistance
        self.routeDistance = routeDistance
    }

    /// From the given array of sample CheckPoints, extract a normalized CheckPoint which shares the same
    /// routeDistance and location of the current CheckPoint
    func extractNormalizedPoint(from samplePoints: [CheckPoint]) -> CheckPoint {
        let boundaryPoints = findAdjacentPoints(from: samplePoints)
        guard let leftCp = boundaryPoints.0,
            let rightCp = boundaryPoints.1 else {
                fatalError("The sample points should contain this point in terms of routeDistance.")
        }
        return CheckPoint.interpolate(with: self.routeDistance, between: leftCp, and: rightCp, on: self.location)
    }

    /// Interpolate a CheckPoint between two CheckPoints, with the given accumulative distance.
    /// The location provided should be the location of the newly interpolated point;
    /// nil indicates that the location of the new point is unknown.
    static func interpolate(with currentDistance: Double, between left: CheckPoint,
                            and right: CheckPoint, on location: Location?) -> CheckPoint {
        let interpolateFraction = (currentDistance - left.routeDistance) / (right.routeDistance - left.routeDistance)
        let newTime = left.time + (right.time - left.time) * interpolateFraction
        let newActualDistance = left.actualDistance + (right.actualDistance - left.actualDistance) * interpolateFraction
        if let newLocation = location {
            return CheckPoint(location: newLocation, time: newTime, actualDistance: newActualDistance, routeDistance: currentDistance)
        } else {
            // location is not known, calculate it from interpolation
            let distanceFromLeft = currentDistance - left.routeDistance
            let newLocation = Location.interpolate(with: distanceFromLeft, between: left.location, and: right.location)
            return CheckPoint(location: newLocation, time: newTime, actualDistance: newActualDistance, routeDistance: currentDistance)
        }
    }

    /// Find the point with the largest distance which is nearer than this point,
    /// and the point with smallest distance which is further than this point.
    /// Return nil for one bound if one of the bound cannot be found.
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
    }
}

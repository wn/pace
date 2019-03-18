//
//  Location.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

struct Location {

    private let longitude: Double
    private let latitude: Double

    /// Constructs a Location with the given longitude and latitude.
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }

    /// Checks if this Location is considered the same another Location.
    /// - Parameter other: the other Location to compare to.
    /// - Returns: true if this location is considered same as the given location.
    func isSameAs(other: Location) -> Bool {
        let distance = distanceTo(other: other)
        return distance <= Constants.sameLocationThreshold
    }

    /// Computes the distance from this Location to another Location.
    /// - Parameter other: the other Location to compute distance against.
    /// - Returns: the distance between this Location to another Location.
    func distanceTo(other: Location) -> Double {
        let xDistance = self.latitude - other.latitude
        let yDistance = self.longitude - other.longitude
        return (xDistance * xDistance - yDistance * yDistance).squareRoot()
    }

    /// Interpolates a new Location between the given two Locations, where the new Location is of the
    /// given distance away from the left Location.
    /// - Parameters:
    ///     - distance: the distance between the new Location and the left Location.
    ///     - left: the left Location.
    ///     - right: the right Location.
    /// - Returns: the interpolated Location.
    static func interpolate(with distance: Double, between left: Location, and right: Location) -> Location {
        let interpolationFraction = distance / left.distanceTo(other: right)
        let newLongitude = left.longitude + (right.longitude - left.longitude) * interpolationFraction
        let newLatitude = left.latitude + (right.latitude - left.latitude) * interpolationFraction
        return Location(longitude: newLongitude, latitude: newLatitude)
    }
}

//
//  Location.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

extension CLLocation {

    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }

    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }

    var asRealmObject: RealmCLLocation {
        return RealmCLLocation(self)
    }

    /// Checks if this Location is considered the same another Location.
    /// - Parameter other: the other Location to compare to.
    /// - Returns: true if this location is considered same as the given location.
    func isSameAs(other: CLLocation) -> Bool {
        let dist = distance(from: other)
        return dist <= Constants.sameLocationThreshold
    }

    /// Interpolates a new Location between the given two Locations, where the new Location is of the
    /// given distance away from the left Location.
    /// - Parameters:
    ///     - distance: the distance between the new Location and the left Location.
    ///     - left: the left Location.
    ///     - right: the right Location.
    /// - Returns: the interpolated Location.
    static func interpolate(with distance: Double, between left: CLLocation, and right: CLLocation) -> CLLocation {
        let interpolationFraction = distance / left.distance(from: right)
        let newLongitude = left.longitude + (right.longitude - left.longitude) * interpolationFraction
        let newLatitude = left.latitude + (right.latitude - left.latitude) * interpolationFraction
        return CLLocation(latitude: newLatitude, longitude: newLongitude)
    }
    
}

class RealmCLLocation: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    convenience init(_ location: CLLocation) {
        self.init()
        latitude = location.latitude
        longitude = location.longitude
    }
    
    var asCLLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

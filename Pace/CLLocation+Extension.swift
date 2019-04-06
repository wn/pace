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
import GoogleMaps

extension CLLocation {

    /// The latitude of the coordinate this `CLLocation` represents.
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }

    /// The longitude of the coordinate this `CLLocation` represents
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }

    /// Returns this location as a Realm-storable object
    var asRealmObject: RealmCLLocation {
        return RealmCLLocation(self)
    }

    /// Returns the address of the coordinate - reverse geocoding
    func address(_ callback: @escaping (String?) -> Void) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(self.coordinate) { response, _ in
            guard let result = response?.firstResult() else {
                return
            }
            callback(result.thoroughfare)
        }
    }

    /// Checks if this Location is considered the same as another Location, based on coordinates only.
    /// - Parameter other: the other Location to compare to.
    /// - Returns: true if this location is considered same as the given location.
    func isSameAs(other: CLLocation) -> Bool {
        let dist = distance(from: other)
        return dist <= Constants.sameLocationThreshold
    }

    /// Custom equality checking used for testing.
    /// The default implementation of == checks pointer equality.
    func isEqualTo(other: CLLocation) -> Bool {
        return latitude == other.latitude
            && longitude == other.longitude
            && altitude == other.altitude
            && horizontalAccuracy == other.horizontalAccuracy
            && verticalAccuracy == other.verticalAccuracy
            && course == other.course
            && speed == other.speed
            && timestamp == other.timestamp
    }

    /// Checks whether this location is near to the give location, within the given distance.
    /// - Parameters:
    ///   - other: The other CLLocation to check against.
    ///   - distance: The distance threshold to check within.
    /// - Returns: true if the two locations are near each other.
    func isNear(_ other: CLLocation, within distance: Double) -> Bool {
        return self.distance(from: other) <= distance
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

/// A wrapper to store `CLLocation` objects into Realm objects.
class RealmCLLocation: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var horizontalAccuracy: Double = 0.0
    @objc dynamic var verticalAccuracy: Double = 0.0
    @objc dynamic var course: Double = 0.0
    @objc dynamic var speed: Double = 0.0
    @objc dynamic var timestamp = Date()

    convenience init(_ location: CLLocation) {
        self.init()
        latitude = location.latitude
        longitude = location.longitude
        altitude = location.altitude
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
        course = location.course
        speed = location.speed
        timestamp = location.timestamp
    }

    convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Returns this `RealmCLLocation` as a `CLLocation` object.
    var asCLLocation: CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                          altitude: altitude,
                          horizontalAccuracy: horizontalAccuracy,
                          verticalAccuracy: verticalAccuracy,
                          course: course,
                          speed: speed,
                          timestamp: timestamp)
    }
}

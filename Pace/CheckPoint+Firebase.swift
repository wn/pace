//
//  CheckPoint+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

extension CheckPoint: FirebaseStorable {
    /// Returns this checkpoint as a Firebase Geopoint.
    var asDictionary: [String: Any] {
        return [
            "time": time,
            "location": realmLocation?.asDictionary ?? [:],
            "actualDistance": actualDistance,
            "routeDistance": routeDistance
        ]
    }

    static func fromDictionary(id: String?, value: [String: Any]) -> CheckPoint? {
        guard
            let time = value["time"] as? Double,
            let location = value["location"] as? [String: Any],
            let actualDistance = value["actualDistance"] as? Double,
            let routeDistance = value["routeDistance"] as? Double
            else {
                return nil
        }
        let locationAsCL = RealmCLLocation.fromDictionary(id: nil, value: location)!.asCLLocation
        return CheckPoint(location: locationAsCL, time: time, actualDistance: actualDistance, routeDistance: routeDistance)
    }
}

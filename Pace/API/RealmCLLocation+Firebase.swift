//
//  RealmCLLocation+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//
import CoreLocation

extension RealmCLLocation: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "longitude": longitude,
            "latitude": latitude,
            "altitude": altitude,
            "speed": speed,
            "course": course
        ]
    }

    static func fromDictionary(objectId: String?, value: [String: Any]) -> RealmCLLocation? {
        guard
            let latitude = value["latitude"] as? Double,
            let longitude = value["longitude"] as? Double
            else {
                return nil
        }
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                     longitude: longitude),
                                  altitude: value["altitude"] as? Double ?? 0,
                                  horizontalAccuracy: 0,
                                  verticalAccuracy: 0,
                                  course: value["course"] as? Double ?? 0,
                                  speed: value["speed"] as? Double ?? 0,
                                  timestamp: Date())
        return RealmCLLocation(location)
    }
}

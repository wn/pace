//
//  RealmCLLocation+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

extension RealmCLLocation: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "longitude": longitude,
            "latitude": latitude
        ]
    }

    static func fromDictionary(id: String?, value: [String: Any]) -> RealmCLLocation? {
        guard
            let latitude = value["latitude"] as? Double,
            let longitude = value["longitude"] as? Double
            else {
                return nil
        }
        return RealmCLLocation(latitude: latitude, longitude: longitude)
    }
}

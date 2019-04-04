//
//  Route+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

extension Route: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "name": name,
            "creator": creator?.id ?? "",
            "startingLocation": [
                "longitude": startingLocation?.longitude ?? 0.0,
                "latitude": startingLocation?.latitude ?? 0.0
            ],
            "creatorRun": creatorRun?.asDictionary ?? [:]
        ]
    }
    
    static func fromDictionary(value: [String : Any]) -> Route? {
        guard
            let name = value["name"] as? String,
            let _ = value["creator"],
            let creatorRun = value["creatorRun"] as? [String: Any]
            else {
                return nil
        }
        return Route(creator: User(name: "newguy"), name: name, creatorRun: Run.fromDictionary(value: creatorRun)!)
    }
}

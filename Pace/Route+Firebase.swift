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
            "startingLongitude": startingLocation?.longitude ?? 0.0,
            "startingLatitude": startingLocation?.latitude ?? 0.0,
            "creatorRun": creatorRun?.asDictionary ?? [:],
            "creatorRunId": creatorRun?.id ?? "",
            "runs": Array(paces.map { $0.id })
        ]
    }
    
    static func fromDictionary(id: String?, value: [String : Any]) -> Route? {
        guard
            let name = value["name"] as? String,
            let _ = value["creator"],
            let creatorRun = value["creatorRun"] as? [String: Any],
            let creatorRunId = value["creatorRunId"] as? String,
            let id = id
            else {
                return nil
        }
        let route = Route(creator: User(name: "newguy"), name: name, creatorRun: Run.fromDictionary(id: creatorRunId, value: creatorRun)!)
        route.id = id
        return route
    }
}

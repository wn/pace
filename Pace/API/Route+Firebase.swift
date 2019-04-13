//
//  Route+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

extension Route: FirebaseStorable {
    var asDictionary: [String: Any] {
        let startingLocation = creatorRun!.startingLocation!
        return [
            "name": name,
            "creator": creator?.objectId ?? "",
            "startingGeohash": Constants.defaultGridManager.getGridId(startingLocation.coordinate).code,
            "creatorRun": creatorRun?.asDictionary ?? [:],
            "creatorRunId": creatorRun?.objectId ?? "",
            "runs": Array(paces.map { $0.objectId })
        ]
    }

    static func fromDictionary(objectId: String?, value: [String: Any]) -> Route? {
        guard
            let name = value["name"] as? String,
            let _ = value["creator"],
            let creatorRun = value["creatorRun"] as? [String: Any],
            let creatorRunId = value["creatorRunId"] as? String,
            let objectId = objectId
            else {
                return nil
        }
        let route = Route(creator: User(name: "newguy"),
                          name: name,
                          creatorRun: Run.fromDictionary(objectId: creatorRunId, value: creatorRun)!)
        route.objectId = objectId
        return route
    }
}

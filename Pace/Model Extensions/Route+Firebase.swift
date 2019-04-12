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
            "creatorName": creator?.name ?? "",
            "creator": creator?.id ?? "",
            "startingGeohash": Constants.defaultGridManager!.getGridId(startingLocation.coordinate).code,
            "creatorRun": creatorRun?.asDictionary ?? [:],
            "creatorRunId": creatorRun?.id ?? "",
            "runs": Array(paces.map { $0.id })
        ]
    }

    static func fromDictionary(id: String?, value: [String: Any]) -> Route? {
        guard
            let name = value["name"] as? String,
            let creatorName = value["creatorName"] as? String,
            let creatorId = value["creator"] as? String,
            let creatorRun = value["creatorRun"] as? [String: Any],
            let creatorRunId = value["creatorRunId"] as? String,
            let id = id
            else {
                return nil
        }
        let route = Route(creator: UserReference(name: creatorName, id: creatorId), name: name, creatorRun: Run.fromDictionary(id: creatorRunId, value: creatorRun)!)
        route.id = id
        return route
    }
}

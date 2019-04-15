//
//  Run+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import FirebaseFirestore

extension Run: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "runnerId": runner?.objectId ?? "",
            "runnerName": runner?.name ?? "",
            "routeId": route.objectId,
            "dateCreated": Timestamp(date: dateCreated),
            "checkPoints": Array(checkpoints.map { $0.asDictionary })
        ]
    }

    static func fromDictionary(objectId: String?, value: [String: Any]) -> Run? {
        guard
            let runnerId = value["runnerId"] as? String,
            let runnerName = value["runnerName"] as? String,
            let checkPoints = value["checkPoints"] as? [[String: Any]],
            let dateCreated = value["dateCreated"] as? Timestamp,
            let objectId = objectId
            else {
                return nil
        }
        let realmCheckpoints = checkPoints.compactMap { CheckPoint.fromDictionary(objectId: nil, value: $0) }
        let run = Run(runner: UserReference(name: runnerName, id: runnerId), checkpoints: realmCheckpoints)
        run.dateCreated = dateCreated.dateValue()
        run.objectId = objectId
        return run
    }
}

//
//  Run+Firebase.swift
//  Pace
//
//  Created by Julius Sander on 5/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Firebase

extension Run: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "runnerName": runner?.name ?? "",
            "runnerId": runner?.id ?? "",
            "routeId": route.id,
            "dateCreated": Timestamp(date: dateCreated),
            "checkPoints": Array(checkpoints.map { $0.asDictionary })
        ]
    }

    static func fromDictionary(id: String?, value: [String: Any]) -> Run? {
        guard
            let runnerId = value["runnerId"] as? String,
            let runnerName = value["runnerName"] as? String,
            let checkPoints = value["checkPoints"] as? [[String: Any]],
            let dateCreated = value["dateCreated"] as? Timestamp,
            let id = id
            else {
                return nil
        }
        let realmCheckpoints = checkPoints.compactMap { CheckPoint.fromDictionary(id: nil, value: $0) }
        let run = Run(runner: UserReference(name: runnerName, id: runnerId), checkpoints: realmCheckpoints)
        run.dateCreated = dateCreated.dateValue()
        run.id = id
        return run
    }
}

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
            "runnerId": runner?.id ?? "",
            "routeId": routes.first!.id,
            "dateCreated": Timestamp(date: dateCreated),
            "checkPoints": checkpoints.map { $0.asDictionary }
        ]
    }
    
    static func fromDictionary(value: [String : Any]) -> Run? {
        guard
            let _ = value["runnerId"] as? String,
            let checkPoints = value["checkPoints"] as? [[String: Any]],
            let dateCreated = value["dateCreated"] as? Timestamp
            else {
                return nil
        }
        let realmCheckpoints = checkPoints.compactMap { CheckPoint.fromDictionary(value: $0) }
        let run = Run(runner: User(name: "name"), checkpoints: realmCheckpoints)
        run.dateCreated = dateCreated.dateValue()
        return run
    }
}

//
//  Route.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Route: FirestoreCodable {
    private let creator: User
    let name: String
    private var paces: [Pace]
    private var checkpoints: [GeoPoint]

    init(creator: User, name: String, paces: [Pace], locations: [GeoPoint]) {
        self.creator = creator
        self.name = name
        self.paces = paces
        self.checkpoints = locations
    }

    required convenience init?(dictionary: [String: Any]) {
        guard
            let name = dictionary["name"] as? String,
            let locations = dictionary["checkpoints"] as? [GeoPoint] else {
                return nil
        }
        self.init(creator: User(id: 0, name: ""), name: name, paces: [], locations: locations)
    }
}

extension Route {
    static let collectionID = CollectionNames.routes

    func toFirestoreDoc() -> [String: Any] {
        return [
            "name": name,
            "location": checkpoints,
        ]
    }
}

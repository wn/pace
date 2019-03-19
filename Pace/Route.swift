//
//  Route.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Route {
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

    init?(dictionary: Dictionary<String, Any>) {
        guard
            let name = dictionary["name"],
            let locations = dictionary["checkpoints"] else {
                return nil
        }
        print("constructing: \(name), \(locations)")
        self.creator = User(id: 0)
        self.name = name as! String
        self.paces = []
        self.checkpoints = locations as! [GeoPoint]
    }

    /// Retrieves all `Route`s from the Firestore database.
    static func all(firestore: Firestore, callback: @escaping ([Route]?) -> Void) {
        let routesRef = firestore.collection("routes")
        routesRef.getDocuments { querySnapshot, err in
            guard err == nil else {
                print("Error acquiring documents")
                return
            }
            let routes = querySnapshot?.documents
                .compactMap { Route(dictionary: $0.data()) }
            callback(routes)
        }
    }
}

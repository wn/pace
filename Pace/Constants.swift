//
//  Constants.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

struct Constants {

    // Threshold distance value to determine whether two locations should be considered as same
    static let sameLocationThreshold = 5.0

    // The default distance interval between two Checkpoints
    static let checkPointDistanceInterval = 20.0
}

/// Identifiers for Firebase collections
struct FireDB {
    static let routes = "routes"
    static let paces = "paces"
    static let users = "users"

    struct Route {
        static let checkpoints = "checkpoints"
        static let name = "name"
        // Foreign Key of User
        static let creatorId = "creator_id"
    }

    struct Pace {
        static let timings = "checkpoint_times"
        // Foreign Key of Route
        static let routeId = "route_id"
        // Foreign Key of User
        static let userId = "user_id"
    }

    struct User {
        static let email = "email"
        static let password = "password"
        static let username = "username"
    }
}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(userId: "VWO0w2OLjw4cnH9B4AnT")
}
    
struct CollectionNames {
    static let paces = "paces"
    static let routes = "routes"
    static let users = "users"
}

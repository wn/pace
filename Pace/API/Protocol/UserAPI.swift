//
//  FirebaseUserAPI.swift
//  Pace
//
//  Created by Julius Sander on 12/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

/// API for user-related methods.
protocol PaceUserAPI {
    typealias RouteResultsHandler = ([Route]?, Error?) -> Void
    typealias RunResultsHandler = ([Run]?, Error?) -> Void
    typealias UserResultsHandler = (User?, Error?) -> Void

    /// Fetches the favourite routes for the user.
    func fetchFavourites(userId: String, _ completion: @escaping RouteResultsHandler)

    /// Finds or creates a user object on the cloud storage.
    func findOrCreateFirebaseUser(with uid: String, _ completion: @escaping UserResultsHandler)

    /// Fetched the runs for this route.
    func fetchRunsForUser(_ user: User, _ completion: @escaping RunResultsHandler)
}

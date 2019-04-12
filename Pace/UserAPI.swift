//
//  UserAPI.swift
//  Pace
//
//  Created by Julius Sander on 12/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

protocol PaceUserAPI {
    typealias RouteResultsHandler = ([Route]?, Error?) -> Void
    typealias RunResultsHandler = ([Run]?, Error?) -> Void
    typealias UserResultHandler = (User?, Error?) -> Void
    /// Authenticates this user
    func authenticate(withFbToken: String, _ completion: @escaping AuthDataResultCallback)
    /// Finds a user object or creates a new user object with this name
    func findUser(withUID: String, orElseCreateWithName: String, _ completion: @escaping UserResultHandler)
    /// Fetches the favourites of the user with this id
    func fetchFavourites(userId: String, _ completion: @escaping RouteResultsHandler)
    /// Fetches the history of the user with this id
    func fetchHistory(userId: String, _ completion: @escaping RunResultsHandler)
}

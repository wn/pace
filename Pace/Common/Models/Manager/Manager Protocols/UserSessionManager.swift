//
//  UserSessionManager.swift
//  Pace
//
//  Created by Julius Sander on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

protocol UserSessionManager {
    typealias BooleanHandler = (Bool) -> Void
    typealias UserResultsHandler = (User?, Error?) -> Void

    /// Gets the user from its facebook uid
    func getRealmUser(_ uid: String?) -> User?

    /// Finds a user with an identifies, or optionally signs up the user/
    func findOrCreateUser(with uid: String, _ completion: @escaping UserResultsHandler)

    func getFavouriteRoutes(of user: User)

    /// Adds to the favourites of the current user.
    func addToFavourites(route: Route, to user: User?, _ completion: BooleanHandler?)

    /// Removes the favourites from the current user.
    func removeFromFavourites(route: Route, from user: User?, _ completion: BooleanHandler?)
}

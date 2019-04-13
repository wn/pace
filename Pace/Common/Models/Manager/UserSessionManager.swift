//
//  UserInteractor.swift
//  Pace
//
//  Created by Julius Sander on 31/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

protocol UserSessionManager {
    typealias BooleanHandler = (Bool) -> Void
    /// The current user in thie session.
    var currentUser: User? { get }
    /// The callback to perform when signed in
    func onSignedInAs(user: User?)
    /// Finds a user with an identifies, or optionally signs up the user/
    func findUserWith(name: String, orSignUp: Bool) -> User?

    func getFavouriteRoutes() -> List<Route>?

    /// Adds to the favourites of the current user.
    func addToFavourites(route: Route, _ completion: BooleanHandler?)

    /// Removes the favourites from the current user.
    func removeFromFavourites(route: Route, _ completion: BooleanHandler?)
}

class RealmUserSessionManager: UserSessionManager {
    static let forDefaultRealm = RealmUserSessionManager()

    private(set) var currentUser: User?

    private var storageManager: RealmStorageManager

    private var realm: Realm {
        return storageManager.persistentRealm
    }

    init(storageManager: RealmStorageManager = CachingStorageManager.default) {
        self.storageManager = storageManager
        // TODO: Proper persistence. Should be able to be handled with Realm Sync.
        onSignedInAs(user: storageManager.persistentRealm.objects(User.self).first)
    }

    func onSignedInAs(user: User?) {
        currentUser = user
    }

    func findUserWith(name: String, orSignUp signUp: Bool = false) -> User? {
        var user = realm.objects(User.self).first {
            $0.name == name
        }
        if user == nil, signUp {
            let newUser = User(name: name)
            try! realm.write {
                realm.add(newUser)
            }
            user = Realm.persistent.objects(User.self).first
        }
        return user
    }

    func getFavouriteRoutes() -> List<Route>? {
        return currentUser?.favouriteRoutes
    }

    func addToFavourites(route: Route, _ completion: BooleanHandler?) {
        var success = true
        do {
            guard let currentUser = currentUser else {
                print("user not found")
                throw NSError()
            }
            storageManager.addFavouriteRoute(route, toUser: currentUser)
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            success = false
        }
        completion?(success)
    }

    func removeFromFavourites(route: Route, _ completion: BooleanHandler?) {
        var success = true
        do {
            guard let currentUser = currentUser else {
                print("user not found")
                throw NSError()
            }
            storageManager.removeFavouriteRoute(route, fromUser: currentUser)
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            success = false
        }
        completion?(success)
    }
}

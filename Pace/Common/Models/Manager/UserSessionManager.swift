//
//  UserInteractor.swift
//  Pace
//
//  Created by Julius Sander on 31/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift
import FacebookCore

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

class RealmUserSessionManager: UserSessionManager {

    static let `default` = RealmUserSessionManager()

    private(set) var storageAPI: PaceUserAPI

    private var storageManager: RealmStorageManager

    private var realm: Realm {
        return storageManager.persistentRealm
    }

    convenience init() {
        self.init(storageManager: CachingStorageManager.default, storageAPI: PaceFirebaseAPI())
    }

    init(storageManager: RealmStorageManager, storageAPI: PaceUserAPI) {
        self.storageManager = storageManager
        self.storageAPI = storageAPI
    }

    /// Gets the realm user based on the uid in the current AccessToken
    /// Optionally can input a uid as an argument to override the access token
    func getRealmUser(_ uid: String?) -> User? {
        guard let currentUid = uid ?? AccessToken.current?.userId else {
            return nil
        }

        return storageManager.persistentRealm.objects(User.self)
            .filter { $0.uid == currentUid }.first
    }

    func findOrCreateUser(with uid: String, _ completion: @escaping UserResultsHandler) {
        storageAPI.findOrCreateFirebaseUser(with: uid) { user, error in
            guard let user = user else {
                return
            }
            try! self.realm.write {
                self.realm.add(user, update: true)
            }
            completion(user, error)
        }
    }

    func getFavouriteRoutes(of user: User) {
        storageAPI.fetchFavourites(userId: user.objectId) { routes, error in
            guard let routes = routes else {
                return
            }
            try! self.realm.write {
                self.realm.add(routes, update: true)
                user.favouriteRoutes.removeAll()
                user.favouriteRoutes.append(objectsIn: routes)
            }
        }
    }

    func addToFavourites(route: Route, to user: User?, _ completion: BooleanHandler?) {
        var success = true
        do {
            guard let user = user else {
                print("user not found")
                throw NSError()
            }
            storageManager.addFavouriteRoute(route, toUser: user)
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            success = false
        }
        completion?(success)
    }

    func removeFromFavourites(route: Route, from user: User?, _ completion: BooleanHandler?) {
        var success = true
        do {
            guard let user = user else {
                print("user not found")
                throw NSError()
            }
            storageManager.removeFavouriteRoute(route, fromUser: user)
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            success = false
        }
        completion?(success)
    }
}

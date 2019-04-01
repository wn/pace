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
    var currentUser: User? { get }
    func signInAs(user: User?)
    func findUserWith(name: String, orSignUp: Bool) -> User?
    func getFavouriteRoutes() -> List<Route>?
    func addToFavourites(route: Route, _ completion: BooleanHandler?)
}

class RealmUserSessionManager: UserSessionManager {
    static let forDefaultRealm = RealmUserSessionManager()

    private(set) var currentUser: User?

    private var realm: Realm

    init(realm: Realm = Realm.getDefault) {
        self.realm = realm
        // TODO: Proper persistence. Should be able to be handled with Realm Sync.
        signInAs(user: realm.objects(User.self).first)
    }

    func signInAs(user: User?) {
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
            user = Realm.getDefault.objects(User.self).first
        }
        return user
    }

    func getFavouriteRoutes() -> List<Route>? {
        return currentUser?.favouriteRoutes
    }

    func addToFavourites(route: Route, _ completion: BooleanHandler?) {
        do {
            guard let userFavourites = getFavouriteRoutes() else {
                throw NSError()
            }
            try Realm.getDefault.write {
                userFavourites.append(route)
            }
            completion?(true)
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            completion?(false)
        }
    }
}

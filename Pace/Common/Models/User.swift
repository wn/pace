//
//  User.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

class User: IdentifiableObject {
    @objc dynamic var name: String = ""
    var favouriteRoutes = List<Route>()
    var routesCreated = LinkingObjects(fromType: Route.self, property: "creator")

    convenience init(name: String) {
        self.init()
        self.name = name
    }

    func addFavouriteRoute(_ route: Route) -> Bool {
        do {
            try Realm.persistent.write {
                favouriteRoutes.append(route)
            }
            return true
        } catch {
            print("Operation unsuccessful: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Hashable
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.objectId == rhs.objectId && lhs.name == rhs.name
    }

    // MARK: - Testing functions
    static func getUser(name: String) -> User {
        var user = Realm.persistent.objects(User.self).first {
            $0.name == name
        }
        if user == nil {
            let newUser = User(name: name)
            try! Realm.persistent.write {
                Realm.persistent.add(newUser)
            }
            user = Realm.persistent.objects(User.self).first
        }
        return user!
    }
}

extension User {
    static var currentUser: User?
}

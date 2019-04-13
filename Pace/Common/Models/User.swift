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
    @objc dynamic var uid: String = ""
    var favouriteRoutes = List<Route>()

    convenience init(name: String) {
        self.init()
        self.name = name
    }

    convenience init(name: String, uid: String) {
        self.init()
        self.name = name
        self.uid = uid
    }

    // MARK: - Hashable
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.objectId == rhs.objectId && lhs.name == rhs.name
    }
}

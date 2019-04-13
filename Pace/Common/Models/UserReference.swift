//
//  UserReference.swift
//  Pace
//
//  Created by Julius Sander on 11/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

/// A structure used to contain the name and id of a user, to be used to load only essential information
/// of a user and his id so his whole profile can be loaded lazily.
class UserReference: Object {
    /// The name of the user this is referring to.
    @objc dynamic var name: String = ""
    /// The id of the user this is referring to.
    @objc dynamic var objectId: String = ""

    convenience init(name: String, id: String) {
        self.init()
        self.name = name
        self.objectId = id
    }

    convenience init(fromUser user: User) {
        self.init(name: user.name, id: user.uid)
    }
}

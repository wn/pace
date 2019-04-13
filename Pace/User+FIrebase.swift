//
//  User+FIrebase.swift
//  Pace
//
//  Created by Julius Sander on 10/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

extension User: FirebaseStorable {
    var asDictionary: [String: Any] {
        return [
            "name": name,
            "uid": uid,
        ]
    }

    static func fromDictionary(objectId: String?, value: [String: Any]) -> User? {
        guard
            let name = value["name"] as? String,
            let uid = value["uid"] as? String,
            let id = objectId
            else {
                return nil
        }
        let user = User(name: name, uid: uid)
        user.objectId = id
        return user
    }
}

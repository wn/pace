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
            "name": name
        ]
    }

    static func fromDictionary(id: String?, value: [String: Any]) -> User? {
        guard let name = value["name"] as? String, let id = id else {
            return nil
        }
        let user = User(name: name)
        user.id = id
        return user
    }
}

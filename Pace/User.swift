//
//  User.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class User: Hashable, FirestoreCodable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    required convenience init?(dictionary: [String : Any]) {
        guard
            let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String
            else {
                return nil
        }
        self.init(id: id, name: name)
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User {
    static let collectionID = CollectionNames.users

    func toFirestoreDoc() -> [String : Any] {
        return [
            "id": id,
            "name": name
        ]
    }
}

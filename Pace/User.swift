//
//  User.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class User: Hashable, FirestoreCodable {
    let userId: Int
    let name: String

    init(userId: Int, name: String) {
        self.userId = userId
        self.name = name
    }

    required convenience init?(dictionary: [String: Any]) {
        guard
            let userId = dictionary["userId"] as? Int,
            let name = dictionary["name"] as? String
            else {
                return nil
        }
        self.init(userId: userId, name: name)
    }

    // MARK: - Hashable
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
}

extension User {
    static let collectionuserId = CollectionNames.users

    func toFirestoreDoc() -> [String: Any] {
        return [
            "userId": userId,
            "name": name
        ]
    }
}

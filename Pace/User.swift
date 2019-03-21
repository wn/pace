//
//  User.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

<<<<<<< HEAD
class User: Hashable {

    let userId: String

    /// Constructs a User with given id.
    init(userId: String) {
        self.userId = userId
=======
class User: Hashable, FirestoreCodable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    required convenience init?(dictionary: [String: Any]) {
        guard
            let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String
            else {
                return nil
        }
        self.init(id: id, name: name)
>>>>>>> cad6c622a22e3f518e4e964aa6d18fbcd8c7a24f
    }

    init?(docId: String, document: [String: Any]) {
        self.userId = docId
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
    static let collectionID = CollectionNames.users

    func toFirestoreDoc() -> [String: Any] {
        return [
            "id": id,
            "name": name
        ]
    }
}

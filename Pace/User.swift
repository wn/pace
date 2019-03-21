//
//  User.swift
//  Pace
//
//  Created by Yuntong Zhang on 16/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class User: Hashable {

    let userId: String

    /// Constructs a User with given id.
    init(userId: String) {
        self.userId = userId
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

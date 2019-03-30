//
//  Route+Retrieval.swift
//  Pace
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

extension User {
    static var currentUser: User? {
        // TODO: proper methos for finding the current user. Definitely with login
        return Realm.getDefault.objects(User.self).first
    }
}

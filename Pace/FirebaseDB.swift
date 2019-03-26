//
//  FirebaseDB.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDB {
    static let firestore = Firestore.firestore()
    static let routes = firestore.collection(FireDB.routes)
    static let paces = firestore.collection(FireDB.paces)
    static let users = firestore.collection(FireDB.users)
    static let friendRequests = firestore.collection(FireDB.friendRequests)
}

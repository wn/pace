//
//  FriendRequest.swift
//  Pace
//
//  Created by Julius Sander on 26/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

class FriendRequest: Object {
    @objc dynamic var receivedFrom: String = ""

    convenience init(_ from: String) {
        self.init()
        receivedFrom = from
    }
}

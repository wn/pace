//
//  IDObject.swift
//  Pace
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a Realm Object that can be identifiable through its primary key.
class IdentifiableObject: Object {
    @objc dynamic var id: String = UUID().uuidString

    override static func primaryKey() -> String? {
        return "id"
    }
}

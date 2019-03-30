//
//  Realm.swift
//  Pace
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

extension Realm {
    static var getDefault = try! Realm()
}

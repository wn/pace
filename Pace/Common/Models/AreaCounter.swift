//
//  AreaCounter.swift
//  Pace
//
//  Created by Julius Sander on 14/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

class AreaCounter: IdentifiableObject {
    @objc dynamic var count: Int = 0

    convenience init(geocode: String, count: Int) {
        self.init()
        self.objectId = geocode
        self.count = count
    }

    convenience init(geocode: String) {
        self.init(geocode: geocode, count: 0)
    }

    func incrementCount() {
        count += 1
    }
}

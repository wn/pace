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
    private static let delimiter: Character = "|"
    var geoCode: String? {
        let idStrings = objectId.split(separator: AreaCounter.delimiter,
                                       maxSplits: 2,
                                       omittingEmptySubsequences: true).map { String($0) }
        guard idStrings.count == 2 else {
            return nil
        }
        return idStrings[0]
    }

    var zoomLevel: Int? {
        let idStrings = objectId.split(separator: AreaCounter.delimiter,
                                       maxSplits: 2,
                                       omittingEmptySubsequences: true).map { String($0) }
        guard idStrings.count == 2, let result = Int(idStrings[1]) else {
            return nil
        }
        return result
    }

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

    static func generateId(_ areaCode: (String, Int)) -> String {
        return "\(areaCode.0)\(delimiter)\(areaCode.1)"
    }
}

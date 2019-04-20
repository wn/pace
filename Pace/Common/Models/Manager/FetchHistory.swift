//
//  FetchHistory.swift
//  Pace
//
//  Created by Julius Sander on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

class FetchHistory: Object {
    @objc dynamic var requestId: String = ""
    @objc dynamic var lastSuccessful: Date = Date(timeIntervalSince1970: 0)

    convenience init(requestType: String, requestId: String) {
        self.init()
        self.requestId = FetchHistory.generateId(requestType: requestType, requestId: requestId)
    }

    func setLastSuccessfulFetch(at date: Date) {
        lastSuccessful = date
    }

    static func generateId(requestType: String, requestId: String) -> String {
        return "\(requestType), \(requestId)"
    }

    override static func primaryKey() -> String? {
        return "requestId"
    }
}

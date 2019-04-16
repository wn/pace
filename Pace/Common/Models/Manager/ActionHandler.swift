//
//  ActionHandler.swift
//  Pace
//
//  Created by Julius Sander on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

class ActionHandler {
    static func getLastFetched(requestType: String, requestId: String, realm: Realm) -> Date {
        let object = realm.object(ofType: FetchHistory.self,
                                  forPrimaryKey: FetchHistory.generateId(requestType: requestType,
                                                                         requestId: requestId))
        if let object = object {
            return object.lastSuccessful
        }
        let newObject = FetchHistory(requestType: requestType, requestId: requestId)
        do {
            try realm.write {
                realm.create(FetchHistory.self, value: newObject, update: true)
            }
        } catch {
            print(error.localizedDescription)
        }
        return newObject.lastSuccessful
    }

    static func updateLastFetched(requestType: String, requestId: String, realm: Realm, date: Date) {
        var object = realm.object(ofType: FetchHistory.self,
                                  forPrimaryKey: FetchHistory.generateId(requestType: requestType,
                                                                         requestId: requestId))
        if object == nil {
            object = FetchHistory(requestType: requestType, requestId: requestId)
        }
        guard let createdObject = object else {
            fatalError("Object should have been created")
        }
        createdObject.setLastSuccessfulFetch(at: date)
        do {
            try realm.write {
                realm.create(FetchHistory.self, value: createdObject, update: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ActionHandler {
    
}

//
//  UploadAttempt.swift
//  Pace
//
//  Created by Julius Sander on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

class UploadAttempt: Object {
    /// The action to take for this attempt.
    @objc dynamic var request: String = ""
    /// The time at which this action was attempted. Used to get the order in which the actions
    /// should be performed.
    @objc dynamic var attemptedAt: Double = 0

    convenience init(request: PaceAction, attemptedAt: Date) {
        self.init()
        self.request = request.asString
        self.attemptedAt = attemptedAt.timeIntervalSince1970
    }

    /// Returns the action to be performed by this attempt.
    func decodeAction() -> PaceAction? {
        return PaceAction.fromString(raw: request)
    }

    /// Returns the list of UploadAttempts in realm.
    static func getAllIn(realm: Realm) -> [UploadAttempt] {
        return Array(realm.objects(self))
            .sorted { $0.attemptedAt < $1.attemptedAt }
    }

    /// Add a new attempt
    static func addNewAttempt(action: PaceAction, toRealm realm: Realm) {
        let newAttempt = UploadAttempt(request: action, attemptedAt: Date(timeIntervalSinceNow: 0))
        do {
            try realm.write {
                realm.add(newAttempt)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

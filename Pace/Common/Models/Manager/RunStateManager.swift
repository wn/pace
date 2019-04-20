//
//  CacheStateManager.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

protocol RunStateManager {

    func getPersistedState() -> RunState?

    func persistRunState(_ state: RunState)

    func clearRunState()
}

class RealmRunStateManager: RunStateManager {
    static let `default` = RealmRunStateManager()

    private(set) var cacheRealm: Realm

    init() {
        cacheRealm = .cache
    }

    /// Saves the RunState to realm
    func persistRunState(_ state: RunState) {
        // Ensure that there are no other 
        clearRunState()
        try! cacheRealm.write {
            Realm.cache.create(RunState.self, value: state, update: true)
        }
    }

    /// Clears the cache of any run states
    func clearRunState() {
        let existingStates = Realm.cache.objects(RunState.self)
        try! cacheRealm.write {
            cacheRealm.delete(existingStates)
        }
    }

    /// Attempts to fetch any existing RunState from realm
    func getPersistedState() -> RunState? {
        return cacheRealm.objects(RunState.self).first
    }
}

//
//  Realm.swift
//  Pace
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

extension Realm {
    static var persistent = try! Realm()

    private static var cacheConfig: Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("cache.realm")
        return config
    }
    static var cache = try! Realm(configuration: cacheConfig)
    static var inMemory: Realm = {
        let configuration = Realm.Configuration(inMemoryIdentifier: "temp")
        return try! Realm(configuration: configuration)
    }()
}

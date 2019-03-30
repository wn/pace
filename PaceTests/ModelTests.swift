//
//  ModelTests.swift
//  PaceTests
//
//  Created by Julius Sander on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Pace

class ModelTests: PaceTests {
    func testAddUser() {
        let angunong = User(name: "angunong")
        let realm = try! Realm()
        var newUser: User?
        do {
            try realm.write {
                realm.add(angunong)
            }
            newUser = realm.objects(User.self).last
            XCTAssertEqual(newUser, angunong, "Expected \(angunong.name), got \(newUser?.name ?? "nil found").")
        } catch {
            XCTFail("Write failed because \(error.localizedDescription)")
        }

        let newName = "new name"
        do {
            try realm.write {
                newUser!.name = newName
            }
            let newerUser = realm.objects(User.self).first
            XCTAssertEqual(newName, newerUser?.name, "Expected \(newName), got \(newerUser?.name ?? "nil found").")
        } catch {
            XCTFail("Write failed because \(error.localizedDescription)")
        }
    }
}

//
//  RouteInteractor.swift
//  Pace
//
//  Created by Julius Sander on 31/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift
import CoreLocation

protocol RouteManager {
    typealias ErrorHandler = (Error) -> Void
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ errorHandler: @escaping ErrorHandler)
    func getRunsFor(route: Route, _ errorHandler: @escaping ErrorHandler)
    func saveNewRoute(_ route: Route, _ completion: ((Error?) -> Void)?)
    func saveNewRun(_ run: Run, toRoute: Route, _ completion: ((Error?) -> Void)?)
}

class RealmRouteManager: RouteManager {

    static let forDefaultRealm = RealmRouteManager()

    private var storageAPI: PaceStorageAPI
    private var realm: Realm
    private var inMemoryRealm: Realm

    private init(persistentRealm: Realm, inMemoryRealm: Realm, storageAPI: PaceStorageAPI) {
        self.realm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
        self.storageAPI = storageAPI
    }

    convenience init() {
        self.init(persistentRealm: .persistent, inMemoryRealm: .inMemory,
                  storageAPI: PaceFirestoreAPI(persistentRealm: .persistent, inMemoryRealm: .inMemory))
    }

    // TODO: complete the implementation
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ errorHandler: @escaping ErrorHandler) {
        storageAPI.fetchRoutesWithin(latitudeMin: longitudeMax, latitudeMax: latitudeMax, longitudeMin: longitudeMin, longitudeMax: longitudeMax) { routes, error in
            guard error == nil, let routes = routes else {
                if let error = error {
                    errorHandler(error)
                }
                return
            }
            routes.forEach { route in
                try! self.inMemoryRealm.write {
                    self.inMemoryRealm.add(route, update: true)
                }
            }
        }
    }

    func saveNewRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        do {
            try realm.write {
                realm.add(route)
            }
            storageAPI.uploadRoute(route, completion)
        } catch {
            print(error.localizedDescription)
        }
    }

    func saveNewRun(_ run: Run, toRoute route: Route, _ completion: ((Error?) -> Void)?) {
        do {
            try realm.write {
                realm.add(run)
            }
            storageAPI.uploadRun(run, forRoute: route, completion)
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRunsFor(route: Route, _ errorHandler: @escaping ErrorHandler) {
        storageAPI.fetchRunsForRoute(route) { runs, error in
            guard error == nil, let runs = runs else {
                if let error = error {
                    errorHandler(error)
                }
                return
            }
            try! route.realm!.write {
                route.paces.append(objectsIn: runs)
            }
        }
    }
}

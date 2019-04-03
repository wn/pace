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
    func getRoutesNear(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                       _ completion: (Results<Route>?, Error?) -> Void)
    func saveNewRoute(_ route: Route, _ completion: ((Error?) -> Void)?)
    func saveNewRun(_ run: Run, toRoute: Route, _ completion: ((Error?) -> Void)?)
    func getRunsFor(route: Route, _ completion: (List<Run>?, Error?) -> Void)
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
    func getRoutesNear(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                       _ completion: (Results<Route>?, Error?) -> Void) {
        let routes = realm.objects(Route.self)
        completion(routes, nil)
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

    // TODO: complete the implementation
    func getRunsFor(route: Route, _ completion: (List<Run>?, Error?) -> Void) {
        completion(route.paces, nil)
    }
}

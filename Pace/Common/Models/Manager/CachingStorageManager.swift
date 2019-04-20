//
//  RouteInteractor.swift
//  Pace
//
//  Created by Julius Sander on 31/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift
import CoreLocation

class CachingStorageManager: RealmStorageManager {

    /// The default RealmStorageManager
    static let `default` = CachingStorageManager()

    /// The API used by this manager to store items.
    private(set) var storageAPI: PaceStorageAPI

    private(set) var persistentRealm: Realm

    private(set) var inMemoryRealm: Realm

    private init(persistentRealm: Realm, inMemoryRealm: Realm, storageAPI: PaceStorageAPI) {
        self.persistentRealm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
        self.storageAPI = storageAPI
    }

    convenience init() {
        self.init(persistentRealm: .persistent,
                  inMemoryRealm: .inMemory,
                  storageAPI: PaceFirebaseAPI())
    }

    // TODO: complete the implementation
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ errorHandler: @escaping ErrorHandler) {
        storageAPI.fetchRoutesWithin(latitudeMin: latitudeMin,
                                     latitudeMax: latitudeMax,
                                     longitudeMin: longitudeMin,
                                     longitudeMax: longitudeMax) { routes, error in
            guard error == nil, let routes = routes else {
                if let error = error {
                    errorHandler(error)
                }
                return
            }
            routes.forEach { route in
                try! self.inMemoryRealm.write {
                    guard self.inMemoryRealm.object(
                        ofType: Route.self,
                        forPrimaryKey: route.objectId) == nil else {
                            return
                    }
                    self.inMemoryRealm.add(route, update: true)
                }
            }
        }
    }

    func getRunsFor(route: Route) {
        storageAPI.fetchRunsForRoute(route.objectId) { runs, error in
            guard let runs = runs, error == nil else {
                return
            }
            try! route.realm!.write {
                let newRuns = runs.map { route.realm!.create(Run.self, value: $0, update: true) }
                newRuns.forEach { newRun in
                    if route.paces.contains(newRun) {
                        return
                    }
                    route.paces.append(newRun)
                }
            }
        }
    }

    /// Fetches runs but loads it into non-persistent memory
    func getRunsFor(routeId: String) {
        storageAPI.fetchRunsForRoute(routeId) { runs, _ in
            guard let runs = runs else {
                return
            }
            try! Realm.inMemory.write {
                Realm.inMemory.add(runs, update: true)
            }
        }
    }

    func getRunsFor(user: User) {
        storageAPI.fetchRunsForUser(user) { runs, error in
            guard let runs = runs, error == nil else {
                return
            }
            try! Realm.persistent.write {
                Realm.persistent.add(runs, update: true)
            }
        }
    }

    func saveNewRoute(_ route: Route, _ completion: ErrorHandler?) {
        do {
            try persistentRealm.write {
                let run = route.creatorRun
                run?.routeId = route.objectId
                persistentRealm.add(route)
            }
            storageAPI.uploadRoute(route, completion)
        } catch {
            print(error.localizedDescription)
        }
    }

    func saveNewRun(_ run: Run, toRoute route: Route, _ completion: ErrorHandler?) {
        do {
            try route.realm?.write {
                run.routeId = route.objectId
                route.paces.append(run)
            }
            storageAPI.uploadRun(run, forRoute: route, completion)
        } catch {
            print(error.localizedDescription)
        }
    }

    func addFavouriteRoute(_ route: Route, toUser user: User, _ completion: ErrorHandler?) {
        do {
            if user.favouriteRoutes.contains(where: { $0.objectId == route.objectId }) {
                return
            }
            try persistentRealm.write {
                let newRoute = persistentRealm.create(Route.self, value: route, update: true)
                user.favouriteRoutes.append(newRoute)
            }
            storageAPI.addFavourite(route, toUser: user, completion)
        } catch {
            print(error.localizedDescription)
        }
    }

    func removeFavouriteRoute(_ route: Route, fromUser user: User, _ completion: ErrorHandler?) {
        do {
            guard let indexToRemove = user.favouriteRoutes.firstIndex(where: { $0.objectId == route.objectId }) else {
                return
            }
            try persistentRealm.write {
                user.favouriteRoutes.remove(at: indexToRemove)
            }
            storageAPI.removeFavourite(route, fromUser: user, completion)
        } catch {
            print(error.localizedDescription)
        }
    }
}
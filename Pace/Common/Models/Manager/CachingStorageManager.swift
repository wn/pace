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

    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping CompletionHandler) {
        storageAPI.fetchRoutesWithin(latitudeMin: latitudeMin,
                                     latitudeMax: latitudeMax,
                                     longitudeMin: longitudeMin,
                                     longitudeMax: longitudeMax) { routes, error in
            guard error == nil, let routes = routes else {
                if let error = error {
                    completion(error)
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

    func getRunsFor(user: User, _ completion: CompletionHandler?) {
        storageAPI.fetchRunsForUser(user) { runs, error in
            guard let runs = runs, error == nil else {
                return
            }
            try! Realm.persistent.write {
                Realm.persistent.add(runs, update: true)
            }
            completion?(error)
        }
    }

    func saveNewRoute(_ route: Route, _ completion: CompletionHandler?) {
        do {
            guard let startingLocation = route.startingLocation else {
                return
            }
            try persistentRealm.write {
                let run = route.creatorRun
                run?.routeId = route.objectId
                persistentRealm.add(route)
            }
            let paceAction = PaceAction.newRoute(route)
            UploadAttempt.addNewAttempt(action: paceAction, toRealm: persistentRealm)
            let areaCodeZoomLevels = Constants.zoomLevels.map {
                (GridMapManager.default.getGridManager(Float($0)).getGridId(startingLocation.coordinate).code, $0)
            }
            self.addRouteToArea(areaCodes: areaCodeZoomLevels, route: route, errorHandler)
            attemptUploads()
        } catch {
            completion?(error)
        }
    }

    func saveNewRun(_ run: Run, toRoute route: Route, _ completion: CompletionHandler?) {
        do {
            try route.realm?.write {
                route.paces.append(run)
            }
            try Realm.persistent.write {
                Realm.persistent.create(Run.self, value: run, update: true)
            }
            let paceAction = PaceAction.newRun(run)
            UploadAttempt.addNewAttempt(action: paceAction, toRealm: persistentRealm)
            attemptUploads {
                completion?(nil)
            }
        } catch {
            completion?(error)
        }
    }

    func addFavouriteRoute(_ route: Route, toUser user: User, _ completion: CompletionHandler?) {
        do {
            if user.favouriteRoutes.contains(where: { $0.objectId == route.objectId }) {
                return
            }
            try persistentRealm.write {
                let newRoute = persistentRealm.create(Route.self, value: route, update: true)
                user.favouriteRoutes.append(newRoute)
            }
            let paceAction = PaceAction.addFavourite(user, route)
            UploadAttempt.addNewAttempt(action: paceAction, toRealm: persistentRealm)
            attemptUploads()
        } catch {
            completion?(error)
        }
    }

    func removeFavouriteRoute(_ route: Route, fromUser user: User, _ completion: CompletionHandler?) {
        do {
            guard let indexToRemove = user.favouriteRoutes.firstIndex(where: { $0.objectId == route.objectId }) else {
                return
            }
            try persistentRealm.write {
                user.favouriteRoutes.remove(at: indexToRemove)
            }
            let paceAction = PaceAction.removeFavourite(user, route)
            UploadAttempt.addNewAttempt(action: paceAction, toRealm: persistentRealm)
            attemptUploads()
        } catch {
            completion?(error)
        }
    }


    func retrieveAreaCount(areaCodes: [(String, Int)], _ errorHandler: CompletionHandler?) {
        areaCodes.forEach { areaCodeZoomLevel in
            let areaCode = AreaCounter.generateId(areaCodeZoomLevel)
            storageAPI.fetchAreaRoutesCount(areaCode: areaCode) { result, error in
                guard let result = result, error == nil else {
                    errorHandler?(error)
                    return
                }
                do {
                    let areaCounter = AreaCounter(geocode: areaCode, count: result)
                    try self.inMemoryRealm.write {
                        self.inMemoryRealm.create(AreaCounter.self, value: areaCounter, update: true)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    /// Increments the area count for an area code. This is done when
    private func addRouteToArea(areaCodes: [(String, Int)], route: Route, _ errorHandler: CompletionHandler?) {
        areaCodes.forEach { areaCode in
            do {
                let counterId = AreaCounter.generateId(areaCode)
                var areaCounter = self.inMemoryRealm.object(ofType: AreaCounter.self, forPrimaryKey: counterId)
                try self.inMemoryRealm.write {
                    if areaCounter == nil {
                        areaCounter = self.inMemoryRealm.create(AreaCounter.self,
                                                                value: AreaCounter(geocode: counterId),
                                                                update: true)
                    }
                    areaCounter?.incrementCount()
                }
                storageAPI.addRouteToArea(areaCode: counterId, route: route, errorHandler)
            } catch {
                errorHandler?(error)
            }
        }
    }

    /// Attempts to upload all objects
    private func attemptUploads() {
        let asyncQueue = AsyncQueue(elements: UploadAttempt.getAllIn(realm: persistentRealm))
        asyncQueue.promiseChain(callback: { uploadAttempt, completion in
            uploadAttempt.decodeAction()?.asAction(self.storageAPI) {
                if $0 == nil {
                    try! self.persistentRealm.write {
                        self.persistentRealm.delete(uploadAttempt)
                    }
                }
                completion($0)
            }
        })
    }

}

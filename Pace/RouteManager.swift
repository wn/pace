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
    func getRoutesNear(coordinate: CLLocationCoordinate2D, _ completion: (Results<Route>?, Error?) -> Void)
    func addNewRoute(route: Route) -> Bool
    func getRunsFor(route: Route, _ completion: (List<Run>?, Error?) -> Void)
}

class RealmRouteManager: RouteManager {
    static let forDefaultRealm = RealmRouteManager()

    private var realm: Realm

    init(realm: Realm = Realm.getDefault, userManager: RealmUserSessionManager = RealmUserSessionManager.forDefaultRealm) {
        self.realm = realm
    }

    // TODO: complete the implementation
    func getRoutesNear(coordinate: CLLocationCoordinate2D, _ completion: (Results<Route>?, Error?) -> Void) {
        let routes = realm.objects(Route.self)
        completion(routes, nil)
    }

    func addNewRoute(route: Route) -> Bool {
        do {
            try realm.write {
                realm.add(route)
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    // TODO: complete the implementation
    func getRunsFor(route: Route, _ completion: (List<Run>?, Error?) -> Void) {
        completion(route.paces, nil)
    }
}

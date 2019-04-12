//
//  FirebaseAPI.swift
//  Pace
//
//  Created by Julius Sander on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Firebase
import RealmSwift
import CoreLocation

protocol PaceStorageAPI {
    /// A typealias for the
    typealias RouteResultsHandler = ([Route]?, Error?) -> Void
    typealias RunResultsHandler = ([Run]?, Error?) -> Void

    /// Fetches the routes stored in the cloud that start within this region.
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping RouteResultsHandler)
    /// Fetched the runs for this route.
    func fetchRunsForRoute(_ route: Route, _ completion: @escaping RunResultsHandler)

    /// Adds the route upload action into the queue, and attempts it.
    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?)

    /// Adds the run upload action into the queue, and attempts it.
    func uploadRun(_ run: Run, forRoute: Route, _ completion: ((Error?) -> Void)?)
}

class PaceFirestoreAPI: PaceStorageAPI {

    private static let rootRef = Firestore.firestore()
    private static let routesRef = rootRef.collection("pace_routes")

    private static func docRefFor(route: Route) -> DocumentReference {
        return routesRef.document(route.id)
    }

    private static let runsRef = rootRef.collection("pace_runs")

    private static func docRefFor(run: Run) -> DocumentReference {
        return runsRef.document(run.id)
    }

    private var persistentRealm: Realm
    private var inMemoryRealm: Realm

    init(persistentRealm: Realm, inMemoryRealm: Realm) {
        self.persistentRealm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
    }

    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping RouteResultsHandler) {
        let geohash = Constants.defaultGridManager.getGridId(CLLocationCoordinate2D(latitude: latitudeMin, longitude: longitudeMin)).code
        print("getting documents for: \n longitude: \(longitudeMin), latitude: \(latitudeMin) \n geohash: \(geohash)")
        let query = PaceFirestoreAPI.routesRef
            .whereField("startingGeohash", isEqualTo: geohash)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            let routes = snapshot?.documents
                .compactMap {
                    Route.fromDictionary(id: $0.documentID, value: $0.data())
                }
            completion(routes, nil)
        }
    }

    func fetchRunsForRoute(_ route: Route, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirestoreAPI.runsRef
            .whereField("routeId", isEqualTo: route.id)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            let runs = snapshot?.documents
                .compactMap {
                    Run.fromDictionary(id: $0.documentID, value: $0.data())
                }
            completion(runs, nil)
        }
    }

    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        let batch = PaceFirestoreAPI.rootRef.batch()
        let routeDocument = PaceFirestoreAPI.docRefFor(route: route)
        batch.setData(route.asDictionary, forDocument: routeDocument, merge: true)
        route.paces.forEach { run in
            let runDocument = PaceFirestoreAPI.docRefFor(run: run)
            batch.setData(run.asDictionary, forDocument: runDocument, merge: true)
        }
        batch.commit(completion: completion)
    }

    func uploadRun(_ run: Run, forRoute route: Route, _ completion: ((Error?) -> Void)?) {
        let batch = PaceFirestoreAPI.rootRef.batch()
        // Set the data for the new run.
        let runDocumentRef = PaceFirestoreAPI.runsRef.document(run.id)
        batch.setData(run.asDictionary, forDocument: runDocumentRef, merge: true)
        // Add the pace into the route.
        let routeDocumentRef = PaceFirestoreAPI.routesRef.document(route.id)
        batch.updateData(["runs": FieldValue.arrayUnion([run.id])], forDocument: routeDocumentRef)
        batch.commit(completion: completion)
    }

}

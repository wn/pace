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

class PaceFirebaseAPI: PaceStorageAPI {

    private static let rootRef = Firestore.firestore()
    private static let routesRef = rootRef.collection("pace_routes")

    private static func docRefFor(route: Route) -> DocumentReference {
        return routesRef.document(route.objectId)
    }

    private static let runsRef = rootRef.collection("pace_runs")

    private static func docRefFor(run: Run) -> DocumentReference {
        return runsRef.document(run.objectId)
    }

    private var persistentRealm: Realm
    private var inMemoryRealm: Realm

    init(persistentRealm: Realm, inMemoryRealm: Realm) {
        self.persistentRealm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
    }

    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping RouteResultsHandler) {
        let geohash = Constants.defaultGridManager
            .getGridId(CLLocationCoordinate2D(latitude: latitudeMin, longitude: longitudeMin)).code
        print("getting documents for: \n longitude: \(longitudeMin), latitude: \(latitudeMin) \n geohash: \(geohash)")
        let query = PaceFirebaseAPI.routesRef
            .whereField("startingGeohash", isEqualTo: geohash)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            let routes = snapshot?.documents
                .compactMap {
                    Route.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            completion(routes, nil)
        }
    }

    func fetchRunsForRoute(_ route: Route, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirestoreAPI.runsRef
            .whereField("routeId", isEqualTo: route.objectId)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            let runs = snapshot?.documents
                .compactMap {
                    Run.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            completion(runs, nil)
        }
    }

    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        let batch = PaceFirebaseAPI.rootRef.batch()
        let routeDocument = PaceFirebaseAPI.docRefFor(route: route)
        batch.setData(route.asDictionary, forDocument: routeDocument, merge: true)
        route.paces.forEach { run in
            let runDocument = PaceFirebaseAPI.docRefFor(run: run)
            batch.setData(run.asDictionary, forDocument: runDocument, merge: true)
        }
        batch.commit(completion: completion)
    }

    func uploadRun(_ run: Run, forRoute route: Route, _ completion: ((Error?) -> Void)?) {
        let batch = PaceFirebaseAPI.rootRef.batch()
        // Set the data for the new run.
        let runDocumentRef = PaceFirestoreAPI.runsRef.document(run.objectId)
        batch.setData(run.asDictionary, forDocument: runDocumentRef, merge: true)
        // Add the pace into the route.
        let routeDocumentRef = PaceFirestoreAPI.routesRef.document(route.objectId)
        batch.updateData(["runs": FieldValue.arrayUnion([run.objectId])], forDocument: routeDocumentRef)
        batch.commit(completion: completion)
    }

}

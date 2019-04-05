//
//  FirebaseAPI.swift
//  Pace
//
//  Created by Julius Sander on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Firebase
import RealmSwift

protocol PaceStorageAPI {
    /// Fetches the routes stored in the cloud that start within this region.
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: ((Error?) -> Void)?)
    /// Fetched the runs for this route.
    func fetchRunsForRoute(_ route: Route, _ completion: ((Error?) -> Void)?)

    /// Adds the route upload action into the queue, and attempts it.
    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?)
    
    /// Adds the run upload action into the queue, and attempts it.
    func uploadRun(_ run: Run, forRoute: Route, _ completion: ((Error?) -> Void)?)
}

class PaceFirestoreAPI: PaceStorageAPI {

    private static let rootRef = Firestore.firestore()
    private static let routesRef = rootRef.collection("routes")
    
    private static func docRefFor(route: Route) -> DocumentReference {
        return routesRef.document(route.id)
    }

    private static let runsRef = rootRef.collection("runs")

    private static func docRefFor(run: Run) -> DocumentReference {
        return routesRef.document(run.route.id).collection("runs").document(run.id)
    }
    
    private var persistentRealm: Realm
    private var inMemoryRealm: Realm

    init(persistentRealm: Realm, inMemoryRealm: Realm) {
        self.persistentRealm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
    }

    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: ((Error?) -> Void)?) {
        let query = PaceFirestoreAPI.routesRef
            .whereField("startingLatitude", isGreaterThanOrEqualTo: Int(latitudeMin))
            .whereField("startingLatitude", isLessThanOrEqualTo: Int(latitudeMax))
        // TODO: make different call and merge with DispatchGroup
            //.whereField("startingLongitude", isGreaterThanOrEqualTo: longitudeMin)
            //.whereField("startingLongitude", isLessThanOrEqualTo: longitudeMax)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                if let completion = completion {
                    completion(err)
                }
                return
            }
            let targetRealm = self.inMemoryRealm
            snapshot?.documents
                .compactMap {
                    Route.fromDictionary(id: $0.documentID, value: $0.data())
                }
                .forEach { route in
                    try! targetRealm.write {
                        targetRealm.create(Route.self, value: route, update: true)
                    }
                }
            if let completion = completion {
                completion(nil)
            }
        }
    }

    func fetchRunsForRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        let query = PaceFirestoreAPI.runsRef
            .whereField("routeId", isEqualTo: route.id)
        query.getDocuments { snapshot, err in
            guard err == nil else {
                if let completion = completion {
                    completion(err)
                }
                return
            }
            let targetRealm = self.inMemoryRealm
            snapshot?.documents
                .compactMap {
                    Run.fromDictionary(id: $0.documentID, value: $0.data())
                }
                .forEach { route in
                    try! targetRealm.write {
                        targetRealm.create(Run.self, value: route, update: true)
                    }
            }
            if let completion = completion {
                completion(nil)
            }
        }
    }

    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        let routeId = route.id
        let batch = PaceFirestoreAPI.rootRef.batch()
        let routeDocument = PaceFirestoreAPI.routesRef.document(routeId)
        batch.setData(route.asDictionary, forDocument: routeDocument, merge: true)
        route.paces.forEach { run in
            let runId = run.id
            let runDocument = routeDocument.collection("runs").document(runId)
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

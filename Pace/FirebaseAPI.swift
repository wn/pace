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
    func requestForRoutes(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                          _ completion: @escaping FIRQuerySnapshotBlock)
    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?)
    func uploadRun(_ run: Run, forRoute: Route, _ completion: ((Error?) -> Void)?)
}

class PaceFirestoreAPI: PaceStorageAPI {

    private static let rootRef = Firestore.firestore()
    private static let routesRef = rootRef.collection("routes")
    private static let runsRef = rootRef.collection("runs")

    private var persistentRealm: Realm
    private var inMemoryRealm: Realm

    init(persistentRealm: Realm, inMemoryRealm: Realm) {
        self.persistentRealm = persistentRealm
        self.inMemoryRealm = inMemoryRealm
    }

    func requestForRoutes(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                          _ completion: @escaping FIRQuerySnapshotBlock) {
        let query = PaceFirestoreAPI.routesRef
            .whereField("latitude", isGreaterThanOrEqualTo: latitudeMin)
            .whereField("latitude", isLessThanOrEqualTo: latitudeMax)
            .whereField("longitude", isGreaterThanOrEqualTo: longitudeMin)
            .whereField("longitude", isLessThanOrEqualTo: longitudeMax)
        query.getDocuments(completion: completion)
    }

    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?) {
        let routeId = route.id
        PaceFirestoreAPI.routesRef
            .document(routeId).setData(route.asDictionary, merge: true, completion: completion)
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

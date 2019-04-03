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
    func uploadRun(_ run: Run, forRoute: Route?, _ completion: ((Error?) -> Void)?)
}

class PaceFirestoreAPI: PaceStorageAPI {
    private static let firestoreRef = Firestore.firestore()
    private static let routesRef = firestoreRef.collection("routes")
    private static let runsRef = firestoreRef.collection("runs")

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

    func uploadRun(_ run: Run, forRoute route: Route?, _ completion: ((Error?) -> Void)?) {
        let runId = run.id
        //let routeId = run.routes.first!.id
        PaceFirestoreAPI.runsRef
            .document(runId).setData(run.asDictionary, merge: true, completion: completion)
    }

}

enum FirebaseError: Error {
    case NotFound
    case NotAuthorised
    case CouldNotConnect
}

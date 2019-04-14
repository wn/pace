//
//  FirebaseAPI.swift
//  Pace
//
//  Created by Julius Sander on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import FirebaseFirestore
import RealmSwift
import CoreLocation

class PaceFirebaseAPI: PaceStorageAPI {

    fileprivate static let rootRef = Firestore.firestore()
    fileprivate static let routesRef = rootRef.collection("pace_routes")

    private static func docRefFor(route: Route) -> DocumentReference {
        return routesRef.document(route.objectId)
    }

    fileprivate static let runsRef = rootRef.collection("pace_runs")

    private static func docRefFor(run: Run) -> DocumentReference {
        return runsRef.document(run.objectId)
    }

    fileprivate var persistentRealm: Realm
    fileprivate var inMemoryRealm: Realm

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
            let routes = snapshot.map {
                $0.documents.compactMap {
                    Route.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            }
            completion(routes, err)
        }
    }

    func fetchRunsForRoute(_ route: Route, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirebaseAPI.runsRef
            .whereField("routeId", isEqualTo: route.objectId)
        query.getDocuments { snapshot, err in
            let runs = snapshot.map {
                $0.documents.compactMap {
                    Run.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            }
            completion(runs, err)
        }
    }

    func fetchRunsForUser(_ user: User, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirebaseAPI.runsRef.order(by: "dateCreated", descending: true)
            .whereField("runnerId", isEqualTo: "3FAEDBA4-2D9B-4B74-8C9C-4D148FF9607D")
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
        let runDocumentRef = PaceFirebaseAPI.runsRef.document(run.objectId)
        batch.setData(run.asDictionary, forDocument: runDocumentRef, merge: true)
        // Add the pace into the route.
        let routeDocumentRef = PaceFirebaseAPI.routesRef.document(route.objectId)
        batch.updateData(["runs": FieldValue.arrayUnion([run.objectId])], forDocument: routeDocumentRef)
        batch.commit(completion: completion)
    }
}

extension PaceFirebaseAPI: PaceUserAPI {
    fileprivate static let usersRef = rootRef.collection("pace_users")

    private static func docRefFor(userId: String) -> DocumentReference {
        return usersRef.document(userId)
    }

    private static func docRefFor(user: User) -> DocumentReference {
        return usersRef.document(user.objectId)
    }

    func findUser(withUID uid: String, orCreateWithName name: String, _ completion: @escaping UserResultsHandler) {
        func createUserWith(name: String) {
            let user = User(name: name, uid: uid)
            PaceFirebaseAPI.usersRef.document(user.objectId).setData(user.asDictionary)
            completion(user, nil)
        }

        let query = PaceFirebaseAPI.usersRef.whereField("uid", isEqualTo: uid)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error != nil else {
                completion(nil, error)
                return
            }
            guard let userDoc = snapshot.documents.first else {
                createUserWith(name: name)
                return
            }
            let user = User.fromDictionary(objectId: userDoc.documentID, value: userDoc.data())
            completion(user, nil)
        }
    }

    func fetchFavourites(userId: String, _ completion: @escaping RouteResultsHandler) {
        let query = PaceFirebaseAPI.routesRef.whereField("favouritedBy", arrayContains: userId)
        query.getDocuments { snapshot, error in
            let routes = snapshot.map {
                $0.documents.compactMap {
                    Route.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            }
            completion(routes, error)
        }
    }

    func fetchHistory(userId: String, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirebaseAPI.runsRef.whereField("creator", isEqualTo: userId)
        query.getDocuments { snapshot, error in
            let history = snapshot.map {
                $0.documents.compactMap {
                    Run.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            }
            completion(history, error)
        }
    }
}
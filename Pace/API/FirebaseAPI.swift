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
import FacebookCore

class PaceFirebaseAPI: PaceStorageAPI {
    /// The reference to the root Firestore reference.
    fileprivate static let rootRef = Firestore.firestore()

    /// The collection reference to the routes Firestore reference.
    fileprivate static let routesRef = rootRef.collection("pace_routes")

    /// The document reference for this route.
    private static func docRefFor(route: Route) -> DocumentReference {
        return routesRef.document(route.objectId)
    }

    /// The collection reference for runs.
    fileprivate static let runsRef = rootRef.collection("pace_runs")

    /// The document reference for this run.
    private static func docRefFor(run: Run) -> DocumentReference {
        return runsRef.document(run.objectId)
    }

    /// The collection reference to the areas Firestore reference.
    private static let areasRef = rootRef.collection("pace_areas")

    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping RouteResultsHandler) {
        PaceFirebaseAPI.routesRef.getDocuments { snapshot, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            let routes = snapshot?.documents
                .compactMap {
                    Route.fromDictionary(objectId: $0.documentID, value: $0.data())
                }
            completion(routes, err)
        }
    }

    func fetchRunsForRoute(_ routeId: String, _ completion: @escaping RunResultsHandler) {
        let query = PaceFirebaseAPI.runsRef
            .whereField("routeId", isEqualTo: routeId)
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
            .whereField("runnerId", isEqualTo: user.objectId)
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

    func fetchAreaRoutesCount(areaCode: String, _ completion: @escaping (Int?, Error?) -> Void) {
        let query = PaceFirebaseAPI.areasRef.document(areaCode)
        query.getDocument { snapshot, error in
            let result = snapshot.map { snap -> Int? in
                guard snap.exists else {
                    return 0
                }
                return (snap.data()?["routes"] as? [String])?.count
            }
            completion(result ?? nil, error)
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

    func uploadRun(_ run: Run, forRouteId routeId: String, _ completion: ((Error?) -> Void)?) {
        let batch = PaceFirebaseAPI.rootRef.batch()
        // Set the data for the new run.
        let runDocumentRef = PaceFirebaseAPI.runsRef.document(run.objectId)
        batch.setData(run.asDictionary, forDocument: runDocumentRef, merge: true)
        // Add the pace into the route.
        let routeDocumentRef = PaceFirebaseAPI.routesRef.document(routeId)
        batch.updateData(["runs": FieldValue.arrayUnion([run.objectId])], forDocument: routeDocumentRef)
        batch.commit(completion: completion)
    }

    func addFavourite(_ route: Route, toUser user: User, _ completion: ((Error?) -> Void)?) {
        let route = PaceFirebaseAPI.docRefFor(route: route)
        route.setData(["favouritedBy": FieldValue.arrayUnion([user.objectId])], merge: true, completion: completion)
    }

    func removeFavourite(_ route: Route, fromUser user: User, _ completion: ((Error?) -> Void)?) {
        let route = PaceFirebaseAPI.docRefFor(route: route)
        route.setData(["favouritedBy": FieldValue.arrayRemove([user.objectId])], merge: true, completion: completion)
    }

    func addRouteToArea(areaCode: String, route: Route, _ completion: ((Error?) -> Void)?) {
        let areaDoc = PaceFirebaseAPI.areasRef.document(areaCode)
        areaDoc.getDocument { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion?(error)
                return
            }
            if snapshot.exists {
                areaDoc.updateData(["routes": FieldValue.arrayUnion([route.objectId])], completion: completion)
            } else {
                areaDoc.setData(["routes": [route.objectId]], merge: true, completion: completion)
            }
        }
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

    /// Creates a user on Firebase
    /// - Parameter uid: Unique facebook id
    private func createFirebaseUser(with uid: String, _ completion: @escaping UserResultsHandler) {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name"]).start({ _, result in
            switch result {
            case .success(let response):
                guard let name = response.dictionaryValue?["name"] as? String else {
                    return
                }
                let user = User(name: name, uid: uid)
                PaceFirebaseAPI.usersRef.document(user.objectId).setData(user.asDictionary)
                completion(user, nil)
            default:
                break
            }
        })
    }

    /// Searches Firebase
    func findOrCreateFirebaseUser(with uid: String, _ completion: @escaping UserResultsHandler) {
        let query = PaceFirebaseAPI.usersRef.whereField("uid", isEqualTo: uid)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error)
                return
            }
            guard let userDoc = snapshot.documents.first else {
                self.createFirebaseUser(with: uid, completion)
                return
            }
            // User found from firebase
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
}

//
//  FirebaseDB.swift
//  Pace
//
//  Created by Tan Zheng Wei on 20/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDB {
    static let firestore = Firestore.firestore()
    static let routes = firestore.collection(FireDB.routes)
    static let paces = firestore.collection(FireDB.paces)
    static let users = firestore.collection(FireDB.users)

    /// Retrieve all Routes
    static func retrieveRoutes(callback: @escaping ([Route]?) -> Void) {
        routes.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error acquiring routes: \(String(describing: error))")
                return
            }
            let routes = snapshot.documents
                .compactMap { Route(docId: $0.documentID, document: $0.data()) }
            callback(routes)
        }
    }

    /// Retrieve Paces of a certain route
    static func retrievePaces(of route: Route, callback: @escaping ([Pace]?) -> Void) {
        guard let routeId = route.docId else {
            return
        }
        paces.whereField(FireDB.Pace.routeId, isEqualTo: routeId).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error acquiring paces of route: \(String(describing: error))")
                return
            }
            let paces = snapshot.documents.compactMap {
                Pace(route: route, docId: $0.documentID, document: $0.data())
            }
            callback(paces)
        }
    }
}

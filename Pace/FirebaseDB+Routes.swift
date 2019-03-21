//
//  FirebaseDB+Routes.swift
//  Pace
//
//  Created by Tan Zheng Wei on 22/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

/* Routes Collection API */
extension FirebaseDB {
    /// Retrieve all Routes
    static func retrieveRoutes(callback: @escaping ([Route]?) -> Void) {
        routes.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error acquiring routes: \(String(describing: error))")
                return
            }
            var routes = [Route]()
            for document in snapshot.documents {
                var data = document.data()
                guard let creatorId = data[FireDB.Route.creatorId] as? String else {
                    continue
                }
                users.document(creatorId).getDocument { userSnapshot, _ in
                    data[FireDB.Route.creatorData] = userSnapshot?.data()
                }
                guard let route = Route(docId: document.documentID, data: document.data()) else {
                    continue
                }
                routes.append(route)
            }
            callback(routes)
        }
    }
}

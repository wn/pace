//
//  UserAPI.swift
//  Pace
//
//  Created by Julius Sander on 12/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

protocol PaceStorageAPI {
    /// A typealias for the routes handler for this protocol.
    typealias RouteResultsHandler = ([Route]?, Error?) -> Void

    /// A typealias for the runs handler for this protocol.
    typealias RunResultsHandler = ([Run]?, Error?) -> Void

    /// Fetches the routes stored in the cloud that start within this region.
    func fetchRoutesWithin(latitudeMin: Double, latitudeMax: Double, longitudeMin: Double, longitudeMax: Double,
                           _ completion: @escaping RouteResultsHandler)
    /// Fetched the runs with the specific routeId
    func fetchRunsForRoute(_ routeId: String, _ completion: @escaping RunResultsHandler)

    /// Fetches the runs for this route.
    func fetchRunsForUser(_ user: User, _ completion: @escaping RunResultsHandler)

    /// Fetches the count of runs in this area.
    func fetchAreaRoutesCount(areaCode: String, _ completion: @escaping ((Int?, Error?) -> Void))

    /// Adds the route upload action into the queue, and attempts it.
    func uploadRoute(_ route: Route, _ completion: ((Error?) -> Void)?)

    /// Adds the run upload action into the queue, and attempts it.
    func uploadRun(_ run: Run, forRouteId: String, _ completion: ((Error?) -> Void)?)

    /// Adds this route to the user's favourites
    func addFavourite(_ route: Route, toUser: User, _ completion: ((Error?) -> Void)?)

    /// Remove this route from the user's favourites
    func removeFavourite(_ route: Route, fromUser: User, _ completion: ((Error?) -> Void)?)

    /// Increments the count of runs in this area.
    func addRouteToArea(areaCode: String, route: Route, _ completion: ((Error?) -> Void)?)
}

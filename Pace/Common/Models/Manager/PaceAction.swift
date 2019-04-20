//
//  PaceAction.swift
//  Pace
//
//  Created by Julius Sander on 20/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

/// The possible actions to save
enum PaceAction {
    case newRoute(Route)
    case newRun(Run)
    case addFavourite(User, Route)
    case removeFavourite(User, Route)
    case addRouteToArea((String, Int), Route)

    static let delimiter: Character = "|"

    enum RequestStrings: String {
        typealias RawValue = String
        case newRoute, newRun, addFavourite, removeFavourite, addRouteToArea
    }

    var asString: String {
        switch self {
        case .newRoute(let route):
            return "\(RequestStrings.newRoute.rawValue)\(PaceAction.delimiter)\(route.objectId)"
        case .newRun(let run):
            return "\(RequestStrings.newRun.rawValue)\(PaceAction.delimiter)\(run.objectId)"
        case .addFavourite(let user, let route):
            return "\(RequestStrings.addFavourite.rawValue)\(PaceAction.delimiter)" +
                "\(user.objectId)\(PaceAction.delimiter)\(route.objectId)"
        case .removeFavourite(let user, let route):
            return "\(RequestStrings.removeFavourite.rawValue)\(PaceAction.delimiter)" +
                "\(user.objectId)\(PaceAction.delimiter)\(route.objectId)"
        case .addRouteToArea(let areaCodeZoomLevel, let route):
            return "\(RequestStrings.addRouteToArea.rawValue)\(PaceAction.delimiter)" +
                "\(areaCodeZoomLevel.0)\(PaceAction.delimiter)\(areaCodeZoomLevel.1)" +
                "\(PaceAction.delimiter)\(route.objectId)"
        }
    }

    static func fromString(raw: String) -> PaceAction? {
        let strings = raw.split(separator: delimiter, maxSplits: 3, omittingEmptySubsequences: true)
            .map { String($0) }
        guard strings.count >= 2 else {
            return nil
        }
        switch strings[0] {
        case RequestStrings.newRoute.rawValue:
            guard strings.count >= 2,
                let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[1]) else {
                return nil
            }
            return .newRoute(route)
        case RequestStrings.newRun.rawValue:
            guard strings.count >= 2,
                let run = Realm.persistent.object(ofType: Run.self, forPrimaryKey: strings[1]) else {
                return nil
            }
            return .newRun(run)
        case RequestStrings.addFavourite.rawValue:
            guard strings.count >= 3,
                let user = Realm.persistent.object(ofType: User.self, forPrimaryKey: strings[1]),
                let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[2]) else {
                    return nil
            }
            return .addFavourite(user, route)
        case RequestStrings.removeFavourite.rawValue:
            guard strings.count >= 3,
                let user = Realm.persistent.object(ofType: User.self, forPrimaryKey: strings[1]),
                let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[2]) else {
                    return nil
            }
            return .removeFavourite(user, route)
        case RequestStrings.addRouteToArea.rawValue:
            guard strings.count >= 4,
                let zoomLevel = Int(strings[2]),
                let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[3]) else {
                    return nil
            }
            return .addRouteToArea((strings[1], zoomLevel), route)
        default:
            return nil
        }
    }

    var asAction: ((PaceStorageAPI, ((Error?) -> Void)?) -> Void) {
        switch self {
        case .newRoute(let route):
            return { storageAPI, completion in
                storageAPI.uploadRoute(route, completion)
            }
        case .newRun(let run):
            return { storageAPI, completion in
                guard let routeId = run.routeId else {
                    return
                }
                storageAPI.uploadRun(run, forRouteId: routeId, completion)
            }
        case .addFavourite(let user, let route):
            return { storageAPI, completion in
                storageAPI.addFavourite(route, toUser: user, completion)
            }
        case .removeFavourite(let user, let route):
            return { storageAPI, completion in
                storageAPI.removeFavourite(route, fromUser: user, completion)
            }
        case .addRouteToArea(let areaCode, let route):
            return { storageAPI, completion in
                storageAPI.addRouteToArea(areaCode: areaCode, route: route, completion)
            }
        }
    }
}

//
//  UploadAttempt.swift
//  Pace
//
//  Created by Julius Sander on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import RealmSwift

class UploadAttempt: Object {
    @objc dynamic var requestId: String = ""
    @objc dynamic var attemptedAt: Date = Date(timeIntervalSinceNow: 0)

    convenience init(requestType: PaceAction, attemptedAt: Date) {
        self.init()
        requestId = requestType.toId
        self.attemptedAt = attemptedAt
    }

    func decodeAction() -> PaceAction? {
        return PaceAction.fromString(raw: requestId)
    }

    /// The possible actions to save
    enum PaceAction {
        case newRoute(Route)
        case newRun(Run)
        case addFavourite(User, Route)
        case removeFavourite(User, Route)

        static let delimiter: Character = "|"

        enum RequestStrings: String {
            typealias RawValue = String
            case newRoute, newRun, addFavourite, removeFavourite
        }

        var toId: String {
            switch self {
            case .newRoute(let route):
                return "\(RequestStrings.newRoute.rawValue)\(PaceAction.delimiter)\(route.objectId)"
            case .newRun(let run):
                return "\(RequestStrings.newRun.rawValue)\(PaceAction.delimiter)\(run.objectId)"
            case .addFavourite(let user, let route):
                return "\(RequestStrings.addFavourite.rawValue)\(PaceAction.delimiter)" + "\(user.objectId)\(PaceAction.delimiter)\(route.objectId)"
            case .removeFavourite(let user, let route):
                return "\(RequestStrings.addFavourite.rawValue)\(PaceAction.delimiter)" + "\(user.objectId)\(PaceAction.delimiter)\(route.objectId)"
            }
        }

        static func fromString(raw: String) -> PaceAction? {
            let strings = raw.split(separator: delimiter, maxSplits: 3, omittingEmptySubsequences: true)
                .map { String($0) }
            switch strings[0] {
            case RequestStrings.newRoute.rawValue:
                guard let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[1]) else {
                    return nil
                }
                return .newRoute(route)
            case RequestStrings.newRun.rawValue:
                guard let run = Realm.persistent.object(ofType: Run.self, forPrimaryKey: strings[1]) else {
                    return nil
                }
                return .newRun(run)
            case RequestStrings.addFavourite.rawValue:
                guard let user = Realm.persistent.object(ofType: User.self, forPrimaryKey: strings[1]),
                    let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[2]) else {
                        return nil
                }
                return .addFavourite(user, route)
            case RequestStrings.removeFavourite.rawValue:
                guard let user = Realm.persistent.object(ofType: User.self, forPrimaryKey: strings[1]),
                    let route = Realm.persistent.object(ofType: Route.self, forPrimaryKey: strings[2]) else {
                        return nil
                }
                return .removeFavourite(user, route)
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
                    storageAPI.uploadRun(run, forRoute: run.route!, completion)
                }
            case .addFavourite(let user, let route):
                return { storageAPI, completion in
                    storageAPI.addFavourite(route, toUser: user, completion)
                }
            case .removeFavourite(let user, let route):
                return { storageAPI, completion in
                    storageAPI.removeFavourite(route, fromUser: user, completion)
                }
            }
        }
    }
}

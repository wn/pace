import Foundation
import CoreLocation
import RealmSwift

struct Constants {

    // Threshold distance value to determine whether two locations should be considered as same
    static let sameLocationThreshold = 5.0

    // The default distance interval between two Checkpoints
    static let checkPointDistanceInterval = 20.0

    // MARK: - MapView location constants
    // mapView constants
    static let initialZoom: Float = 18
    static let guardDistance: CLLocationDistance = 10
        // New location must be greater than guardDistance for map to update

    // MARK: - Realm constants
    static let paceCloudInstanceAddress = "pace.us1.cloud.realm.io"

    static let AuthURL = "https://\(paceCloudInstanceAddress)"
    static let RealmURL = "https://\(paceCloudInstanceAddress)/pace"

}

/// Identifiers for Firebase collections
struct FireDB {
    static let routes = "routes"
    static let paces = "paces"
    static let users = "users"
    static let friendRequests = "friend_requests"

    struct Route {
        static let checkpoints = "checkpoints"
        static let name = "name"
        // Foreign Key of User
        static let creatorId = "creator_id"
        // (Not in firebase) Added field to load creator (user) data for each route
        static let creatorData = "creator_data"
    }

    struct Pace {
        static let timings = "checkpoint_times"
        static let distances = "route_distances"
        // Foreign Key of Route
        static let routeId = "route_id"
        // Foreign Key of User
        static let userId = "user_id"
        // (Not in firebase) Added field to load user data for each pace
        static let userData = "user_data"
    }

    struct User {
        static let email = "email"
        static let password = "password"
        static let username = "username"
        static let name = "name"
    }
}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(name: "angunong")
}

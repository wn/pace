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
    static let initialZoom: Float = 17.5
    // Horizontal accuracy must be greater than guardDistance for map to update
    static let guardAccuracy: CLLocationDistance = 25
    static let minZoom: Float = 11.5
    static let maxZoom: Float = 18.5
    static let minZoomToShowRoutes: Float = 17.1

    // MARK: - Realm constants
    static let paceCloudInstanceAddress = "pace.us1.cloud.realm.io"

    static let AuthURL = "https://\(paceCloudInstanceAddress)"
    static let RealmURL = "https://\(paceCloudInstanceAddress)/pace"
    
    // MARK: Locale variables
    static let locale = "en_SG"
}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(name: "angunong")
}

struct Identifiers {
    static let pace = "paceIdentifier"
    static let userStats = "userStatsIdentifier"
    static let runAnalysisController = "runAnalysisController"
}

struct Titles {
    static let profile = "Profile"
    static let run = "Run"
}

struct Xibs {
    static let runCollectionViewCell = "RunCollectionViewCell"
    static let routeCollectionViewCell = "RouteCollectionViewCell"
    static let userStatsView = "UserStatsView"
}

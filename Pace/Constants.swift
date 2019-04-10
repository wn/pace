import Foundation
import CoreLocation
import RealmSwift

struct Constants {

    // MARK: - Model constants
    // Threshold distance value to determine whether two locations should be considered as same
    static let sameLocationThreshold = 5.0
    // The default distance interval between two Checkpoints
    static let checkPointDistanceInterval = 20.0
    // Covered checkpoints percentage threshold to determine whether can be the same route
    static let sameRoutePercentageOverlapThreshold = 0.8

    // MARK: - MapView location constants
    // googleMapView constants
    static let initialZoom: Float = 17.5
    // Horizontal accuracy must be greater than guardDistance for map to update
    static let guardAccuracy: CLLocationDistance = 25
    static let minZoom: Float = 1.5
    static let maxZoom: Float = 18.5
    static let minZoomToShowRoutes: Float = 15

    // MARK: - Run constants
    static let startFlag = "start-flag.png"
    static let endFlag = "end-flag.png"
    static let startButton = "start-icon.png"
    static let endButton = "end-icon.png"

    static let gridWidth: Double = 300
    static let gridHeight: Double = 300

    // MARK: - Default objects
    static var defaultGridManager: GridMap {
        guard let result = GridMap(width: Constants.gridWidth, height: Constants.gridHeight) else {
            fatalError("Width or height of grid must be greater than 0.")
        }
        return result
    }

    // MARK: Locale variables
    static let locale = "en_SG"
}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(name: "angunong")
}

struct Identifiers {
    static let runCell = "runCell"
    static let routeCell = "routeCell"
    static let userStats = "userStatsIdentifier"
    static let runAnalysisController = "runAnalysisController"
}

struct Titles {
    static let profile = "Profile"
    static let favourites = "Favourites"
    static let run = "Run"
}

struct Xibs {
    static let runCollectionViewCell = "RunCollectionViewCell"
    static let routeCollectionViewCell = "RouteCollectionViewCell"
    static let userStatsView = "UserStatsView"
}

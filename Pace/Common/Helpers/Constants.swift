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
    static let mapAspectRatio: Double = 4 / 3
    // Horizontal accuracy must be greater than guardDistance for map to update
    static let guardAccuracy: CLLocationDistance = 25
    static let minZoom: Int = 12
    static let maxZoom: Int = 19
    static let zoomLevels = [16, Constants.maxZoom]

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
    static let storyboard = "Main"
    static let runCell = "runCell"
    static let routeCell = "routeCell"
    static let userStats = "userStatsIdentifier"
    static let summaryViewController = "SummaryVC"
    static let searchViewController = "SearchViewController"
    static let runAnalysisController = "runAnalysisController"
    static let runCollectionController = "RunCollectionController"
    static let compareRunCell = "compareRunCell"
}

struct Titles {
    static let activity = "Activity"
    static let profile = "Profile"
    static let favourites = "Favourites"
    static let run = "Run"
}

struct Xibs {
    static let runCollectionViewCell = "RunCollectionViewCell"
    static let compareRunCollectionViewCell = "CompareRunCollectionViewCell"
    static let routeCollectionViewCell = "RouteCollectionViewCell"
    static let runGraphView = "RunGraphView"
    static let userStatsView = "UserStatsView"
}

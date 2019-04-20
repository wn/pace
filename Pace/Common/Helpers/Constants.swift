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
    static let minZoom: Int = 12
    static let maxZoom: Int = 18
    static var zoomLevels: [Int] {
        return Array(gridMaps.keys)
    }

    // MARK: - Run constants
    static let startFlag = "start-flag.png"
    static let endFlag = "end-flag.png"
    static let startButton = "start-icon.png"
    static let endButton = "end-icon.png"

    static let gridMaps: [Int: GridMap] = {
        guard
            let zoom13 = GridMap(width: 10_000, height: 10_000),
            let zoom16 = GridMap(width: 1_600, height: 1_600),
            let zoomMax = GridMap(width: 400, height: 400) else {
                fatalError("We should not init GridMap with negative sides.")
        }
        return [13: zoom13, 16: zoom16, maxZoom: zoomMax]
    }()

    static var defaultGridManager: GridMap {
        guard let defaultGM = gridMaps[maxZoom] else {
            fatalError("GridMaps should include a gridmap at max zoom.")
        }
        return defaultGM
    }

    // MARK: Locale variables
    static let locale = "en_SG"
}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(name: "angunong")
    static let follower = User(name: "darth vader")
}

struct Identifiers {
    static let storyboard = "Main"
    static let runCell = "runCell"
    static let routeCell = "routeCell"
    static let userStats = "userStatsIdentifier"
    static let summaryViewController = "summaryVC"
    static let searchViewController = "SearchViewController"
    static let runAnalysisController = "runAnalysisController"
    static let runCollectionController = "RunCollectionController"
    static let compareRunCell = "compareRunCell"
    static let modeViewCell = "modeViewCell"
    static let graphModeSelectController = "GraphModeSelectController"
    static let unwindToRunAnalysisSegue = "unwindToRunAnalysisSegue"
}

struct Titles {
    static let activity = "Activity"
    static let runSummary = "Run Summary"
    static let profile = "Profile"
    static let favourites = "Favourites"
    static let run = "Run"
}

struct Xibs {
    static let runStatsView = "RunStatsView"
    static let runCollectionViewCell = "RunCollectionViewCell"
    static let compareRunCollectionViewCell = "CompareRunCollectionViewCell"
    static let routeCollectionViewCell = "RouteCollectionViewCell"
    static let runGraphView = "RunGraphView"
    static let userStatsView = "UserStatsView"
    static let loginView = "LoginView"
}

struct Images {
    static let saveButton = "save.png"
    static let soundIcon = "sound.png"
    static let muteIcon = "mute.png"
    static let wifiIcon = "wifi.png"
    static let asterick = "asterick.png"
}

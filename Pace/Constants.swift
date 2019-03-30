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
    // New location must be greater than guardDistance for map to update
    static let guardDistance: CLLocationDistance = 10

    // MARK: - Realm constants
    static let paceCloudInstanceAddress = "pace.us1.cloud.realm.io"

    static let AuthURL = "https://\(paceCloudInstanceAddress)"
    static let RealmURL = "https://\(paceCloudInstanceAddress)/pace"

}

/// For Development Purposes until the rest of the interface is ready
struct Dummy {
    static let user = User(name: "angunong")
}

//
//  GridMapManager.swift
//  Pace
//
//  Created by Ang Wei Neng on 15/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import CoreLocation

class GridMapManager {
    static let `default` = GridMapManager()
    var gridMapManagers: [Int: GridMap] = Constants.gridMaps

    func getGridManager(_ zoomLevel: Float) -> GridMap {
        guard
            let gridMapManager = gridMapManagers[getNearestZoom(zoomLevel)] else {
                fatalError("We must have a gridMap since gridMapManagers covers all range of zoom")
        }
        return gridMapManager
    }

    func getNearestZoom(_ zoomLevel: Float) -> Int {
        guard let result = Array(Constants.zoomLevels).filter({ $0 >= Int(zoomLevel.rounded(.up))}).min() else {
            fatalError()
        }
        return result
    }

    func getGridId(zoom: Float, position: CLLocationCoordinate2D) -> GridNumber {
        let gridManager = getGridManager(zoom)
        return gridManager.getGridId(position)
    }
}

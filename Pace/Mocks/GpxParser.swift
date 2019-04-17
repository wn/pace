//
//  GpxParser.swift
//
//  Created by Manish Katoch on 11/29/17.
//  From: https://hackernoon.com/simulating-user-location-and-navigation-route-on-iphone-without-xcode-761f06905f1c
//  Copyright © 2017 Manish Katoch. All rights reserved.
//

import Foundation
import CoreLocation

protocol GpxParsing: NSObjectProtocol {
    func parser(_ parser: GpxParser, didCompleteParsing locations: [CLLocation])
}

class GpxParser: NSObject, XMLParserDelegate {
    private var locations: [CLLocation]
    weak var delegate: GpxParsing?
    private var parser: XMLParser?

    init(forResource file: String, ofType typeName: String) {
        self.locations = [CLLocation]()
        super.init()
        if let content = try? String(contentsOfFile: Bundle.main.path(forResource: file, ofType: typeName)!) {
            let data = content.data(using: .utf8)
            parser = XMLParser(data: data!)
            parser?.delegate = self
        }
    }

    func parse() {
        self.parser?.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "trkpt":
            guard let latString = attributeDict["lat"],
                let lat = Double(latString),
                let lonString = attributeDict["lon"],
                let lon = Double(lonString),
                let eleString = attributeDict["ele"],
                let ele = Double(eleString) else {
                return
            }
            locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat,
                                                                           longitude: lon),
                                        altitude: ele,
                                        horizontalAccuracy: 0,
                                        verticalAccuracy: 0,
                                        course: 0,
                                        speed: 0,
                                        timestamp: Date()))
        default: break
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.parser(self, didCompleteParsing: locations)
    }
}

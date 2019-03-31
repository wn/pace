//
//  CLLocationExtensionSpec.swift
//  PaceTests
//
//  Created by Yuntong Zhang on 30/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import CoreLocation
@testable import Pace

class CLLocationExtensionSpec: QuickSpec {
    override func spec() {
        describe("a CLLocation") {
            var location: CLLocation!
            beforeEach { location = CLLocation(latitude: 1.35210, longitude: 103.81983) }

            describe("compares with another CLLocation") {
                context("when the distance is smaller than the threshold") {
                    var nearLocation: CLLocation!
                    beforeEach {
                        nearLocation = CLLocation(latitude: 1.35211, longitude: 103.81984)
                        assert(location.distance(from: nearLocation) <= Constants.sameLocationThreshold)
                    }
                    it("should be the same location") {
                        expect(location.isSameAs(other: nearLocation)).to(beTrue())
                    }
                }

                context("when the distance is bigger than the threshold") {
                    var farLocation: CLLocation!
                    beforeEach {
                        farLocation = CLLocation(latitude: 2.35210, longitude: 104.81983)
                        assert(location.distance(from: farLocation) >= Constants.sameLocationThreshold)
                    }
                    it("should not be the same location") {
                        expect(location.isSameAs(other: farLocation)).to(beFalse())
                    }
                }
            }

            describe("converts to RealmCLLocation") {
                it("should be the same when converting back") {
                    let realmLocation = location.asRealmObject
                    let convertedBackLocation = realmLocation.asCLLocation
                    expect(convertedBackLocation.isEqualTo(other: location)).to(beTrue())
                }
            }
        }
    }
}

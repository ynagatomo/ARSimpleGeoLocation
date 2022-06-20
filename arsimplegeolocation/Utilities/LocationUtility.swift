//
//  LocationUtility.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/19.
//

import Foundation
import CoreLocation

class LocationUtility {
    private init() {}

    struct Location {
        let latitude: Double
        let longitude: Double
        let altitude: Double?
    }

    // Calculate the difference of two geographical locations and Return
    // in meters on three axises (x, y, z); diff = from - base
    static func locationDiff(base: Location, from: Location) -> SIMD3<Float> {
        let baseCLLocation = CLLocation(latitude: base.latitude,
                                        longitude: base.longitude)
        // diff X
        let fromCLLocationX = CLLocation(latitude: base.latitude, // use base
                                        longitude: from.longitude)
        var distanceX = baseCLLocation.distance(from: fromCLLocationX) // [meters]
        assert(distanceX >= 0)

        if from.longitude < base.longitude { // +X : +longitude
            distanceX *= -1
        }
        // The distance is calculated between shortest arc on the earth.
        // Adjust the direction.
        let direction: Double = abs(base.longitude - from.longitude) > 180.0 ? -1 : 1
        distanceX *= direction

        // diff Z
        let fromCLLocationZ = CLLocation(latitude: from.latitude,
                                         longitude: base.longitude) // use base
        var distanceZ = baseCLLocation.distance(from: fromCLLocationZ) // [meters]
        assert(distanceZ >= 0)
        if from.latitude > base.latitude { // +Z : -latitude
            distanceZ *= -1
        }

        // diff Y
        var distanceY: Float = 0 // if altitude is not available, offsetY is zero
        if let baseAltitude = base.altitude,
           let fromAltitude = from.altitude {
            distanceY = Float(fromAltitude - baseAltitude)
        }

        return SIMD3<Float>(Float(distanceX),
                            Float(distanceY),
                            Float(distanceZ)) // [meters]
    }

    // Calculate the distance in meters between two geographical locations
    // return value is almost less than 20,000 km
    static func distance(_ baseLoc: Location, from fromLoc: Location) -> Double {
        let baseCLLocation = CLLocation(latitude: baseLoc.latitude,
                                        longitude: baseLoc.longitude)
        let fromCLLocation = CLLocation(latitude: fromLoc.latitude,
                                        longitude: fromLoc.longitude)
        // Returns the distance (in meters) between the two locations.
        // [Note]
        //   The distance method measures the distance between the
        //   location in the current object and the value in the location
        //   parameter. The distance is calculated by tracing a line
        //   between the two points that follows the curvature of the Earth,
        //   and measuring the length of the resulting arc. The arc is a
        //   smooth curve that doesn’t take into account altitude changes
        //   between the two locations.
        let distance = baseCLLocation.distance(from: fromCLLocation)
        assert(distance >= 0)
        return distance
    }
}

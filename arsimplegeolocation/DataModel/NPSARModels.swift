//
//  NPSARModels.swift
//  arsimplegeolocation
//
//  Created by Ruben Hansen-Rojas on 10/30/22.
//

import Foundation

/// A type that defines geographic coordinates.
public protocol GeographicallyPlaceable {
    
    /// A latitude specified in degrees.
    var latitude: Double { get }
    
    /// A longitude specified in degrees.
    var longitude: Double { get }
    
    /// An altitude specified  in meters.
    var altitude: Double { get }
}

/// A place as defined by the NPS places API.
struct NPSPlace: GeographicallyPlaceable {
    // https://www.nps.gov/subjects/developer/api-documentation.htm#/places/getPlaces
    public private(set) var latitude: Double
    public private(set) var longitude: Double
    public private(set) var altitude: Double
}

extension NPSPlace {
    
    /// Initializer.
    /// - Parameters:
    ///   - json: A key/value mapping.
    init(json: [String: Any]) {
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        var altitude: Double = 0.0
        
        if let jsonLat = json["latitude"] as? Double {
            latitude = jsonLat
        }
        
        if let jsonLon = json["longitude"] as? Double {
            longitude = jsonLon
        }
        
        if let jsonAlt = json["altitude"] as? Double {
            altitude = jsonAlt
        }
        
        self.init(latitude: latitude, longitude: longitude, altitude: altitude)
    }
    
    static func ParkerOfficeDesk() -> NPSPlace {
        return NPSPlace(latitude: 39.51996788283484,
                        longitude: -104.79974943077401,
                        altitude: 1804.0)
    }
    
    static func ParkerOfficeDeskAppDebug() -> NPSPlace {
        return NPSPlace(latitude: 39.519965,
                        longitude: -104.799824,
                        altitude: 1801.0)
    }

    static func ParkerOfficeAcrossTheStreet() -> NPSPlace {
        return NPSPlace(latitude: 39.52033,
                        longitude: -104.80062,
                        altitude: 1803.0)
    }
    
    static func ParkerOfficeCattyCorner() -> NPSPlace {
        return NPSPlace(latitude: 39.52030,
                        longitude: -104.79962,
                        altitude: 1803.0)
    }
}

extension ModelAsset {
    
    init(assetName: String,
         thumbnailFile: String,
         assetFile: String,
         place: GeographicallyPlaceable) {
        
        self.init(id: UUID(),
                  name: assetName,
                  thumbnailFile: thumbnailFile,
                  assetFile: assetFile,
                  scale: SIMD3<Float>(0.01, 0.01, 0.01),
                  orientationOnYAxis: 0,
                  approachingDistance: 5.0,
                  distanceAway: 10.0,
                  latitude: place.latitude,
                  longitude: place.longitude,
                  altitude: place.altitude)
    }
}

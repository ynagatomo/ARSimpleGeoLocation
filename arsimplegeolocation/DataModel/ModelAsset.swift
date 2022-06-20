//
//  ModelAsset.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import Foundation

struct ModelAsset: Identifiable {
    let id: UUID
    let name: String           // asset name
    let thumbnailFile: String? // thumbnail file name
    let assetFile: String      // USDZ or reality file name in bundle

    let scale: SIMD3<Float>    // display scale
    let orientationOnYAxis: Float   // [rad]
    let approachingDistance: Double // [m]
    let distanceAway: Double // [m]

    let latitude: Double    // [deg] location to place the model
    let longitude: Double   // [deg]
    let altitude: Double    // [m]
}

//
//  ModelDataSet.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/19.
//

import Foundation

class ModelDataSet {
    private init() {}

    // Add model assets you want to display in AR scenes
    static let dataSet: [ModelAsset] = [
        // (c)Apple, from Apple AR Quick Library
        // https://developer.apple.com/augmented-reality/quick-look/
        // size (x, y, z) = (6, 7.32, 4.63) [m]
        ModelAsset(
            id: UUID(),
            name: "Drummer",
            thumbnailFile: "drummer128",
            assetFile: "toy_drummer",
            scale: SIMD3<Float>(1, 1, 1),
            orientationOnYAxis: 0,
            approachingDistance: 10.0, // [m]
            distanceAway: 20.0, // [m]
            latitude: 35.68157,   // Tokyo station <== please change to a location near you
            longitude: 139.76561, //               <== please change to a location near you
            altitude: 3.5),       //               <== please change to a location near you

        ModelAsset(
            id: UUID(),
            name: "Robot",
            thumbnailFile: "robot128",
            assetFile: "toy_robot_vintage",
            scale: SIMD3<Float>(1, 1, 1),
            orientationOnYAxis: 0,
            approachingDistance: 10.0, // [m]
            distanceAway: 20.0, // [m]
            latitude: 35.68138,   // Tokyo station <== please change to a location near you
            longitude: 139.76543, //               <== please change to a location near you
            altitude: 3.5),       //               <== please change to a location near you

        ModelAsset(
            id: UUID(),
            name: "Plane",
            thumbnailFile: "plane128",
            assetFile: "toy_biplane",
            scale: SIMD3<Float>(1, 1, 1),
            orientationOnYAxis: 0,
            approachingDistance: 10.0, // [m]
            distanceAway: 20.0, // [m]
            latitude: 35.68132,   // Tokyo station <== please change to a location near you
            longitude: 139.76547, //               <== please change to a location near you
            altitude: 3.5)        //               <== please change to a location near you
    ]
}

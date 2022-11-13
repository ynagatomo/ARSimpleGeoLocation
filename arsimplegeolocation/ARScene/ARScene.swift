//
//  ARScene.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import UIKit
import RealityKit
import Combine

final class ARScene {
    private var anchor: AnchorEntity!
    private var arView: ARView!

    enum SceneState: Int {
        case none = 0, setup
    }
    private var sceneState = SceneState.none
    struct GeoEntity {
        let id: UUID
        let name: String
        let latitude: Double
        let longitude: Double
        let altitude: Double
        let distanceAway: Double
        let entity: Entity
    }
    private var geoEntities: [GeoEntity] = []
    private var lastDeviceLocation: DeviceLocation!
    private var lastDeviceTranslation: SIMD3<Float>!

    init(arView: ARView, anchor: AnchorEntity) {
        self.anchor = anchor
        self.arView = arView
    }

    func setupScene() {
        // do nothing
    }

    func startSession() {
        startAnimation()
    }

    func stopSession() {
        stopAnimation()
    }

    private func startAnimation() {
        // do nothing
    }

    private func stopAnimation() {
        // do nothing
    }
}

extension ARScene {
    // Update the device's geographical location and adjust virtual object's position
    // in the virtual space, according to the changes of geographical location
    func updateLocation(device: DeviceLocation?, assets: [ModelAsset]) {
        debugLog("updateLocation(device:assets:) was called.")
        
        let horizontalAccuracyLimit = (sceneState == .none) ? 5.0 : 4.9
        let verticalAccuracyLimit = (sceneState == .none) ? 5.0 : 3.1
        
        guard let device,
              !assets.isEmpty,
              (device.horizontalAccuracy < horizontalAccuracyLimit),
              (device.verticalAccuracy < verticalAccuracyLimit) else {
            return
        }
            
        let currentDeviceLocation = device // in real space
        let currentDeviceTranslation = arView.cameraTransform.translation // in virtual space
        
        if sceneState == .none {
            // setup the virtual world
            setupGeoEntities(currentDeviceLocation: currentDeviceLocation,
                             currentDeviceTranslation: currentDeviceTranslation,
                             assets: assets)
            sceneState = .setup  // The scene was set up.
        } else {
            // update the virtual world
            updateGeoEntities(currentDeviceLocation: currentDeviceLocation,
                              currentDeviceTranslation: currentDeviceTranslation,
                              assets: assets)
        }

        lastDeviceLocation = currentDeviceLocation
        lastDeviceTranslation = currentDeviceTranslation
    }

    private func setupGeoEntities(currentDeviceLocation: DeviceLocation,
                                  currentDeviceTranslation: SIMD3<Float>,
                                  assets: [ModelAsset]) {
        let deviceLoc = LocationUtility.Location(latitude: currentDeviceLocation.latitude,
                         longitude: currentDeviceLocation.longitude,
                         altitude: currentDeviceLocation.altitude)

        let addingAssets = assets.filter({
            let assetLoc = LocationUtility.Location(latitude: $0.latitude,
                                                    longitude: $0.longitude,
                                                    altitude: $0.altitude)
            return LocationUtility.distance(deviceLoc, from: assetLoc) < $0.approachingDistance
        })

        addGeoEntities(deviceTranslation: currentDeviceTranslation,
                       deviceLoc: deviceLoc, addingAssets: addingAssets)
    }

    private func addGeoEntities(deviceTranslation: SIMD3<Float>,
                                deviceLoc: LocationUtility.Location,
                                addingAssets: [ModelAsset]) {
        addingAssets.forEach {
            if let model = try? Entity.load(named: $0.assetFile) {
                let geoEntity = GeoEntity(id: $0.id,
                                          name: $0.name,
                                          latitude: $0.latitude,
                                          longitude: $0.longitude,
                                          altitude: $0.altitude,
                                          distanceAway: $0.distanceAway,
                                          entity: model)
                
                var scale = model.scale(relativeTo: nil)
                debugLog("model scale relative to parent: \(scale)")
                model.orientation = simd_quatf(angle: $0.orientationOnYAxis,
                                               axis: SIMD3<Float>(0, 1, 0))
                model.scale = $0.scale

                let entityLoc = LocationUtility.Location(latitude: $0.latitude,
                                 longitude: $0.longitude,
                                 altitude: $0.altitude)
                let diffXYZ = LocationUtility.locationDiff(base: deviceLoc,
                                                                from: entityLoc)
                let entityTranslation = deviceTranslation + diffXYZ
                model.transform.translation = entityTranslation

                anchor.addChild(model)
                geoEntities.append(geoEntity)
                
                scale = model.scale(relativeTo: nil)
                debugLog("model scale relative to parent: \(scale)")

                if let animation = model.availableAnimations.first {
                    model.playAnimation(animation.repeat())
                }

                debugLog("added the model `\($0.name)` to the virtual space.")
            } else {
                fatalError("failed to load the Model file `\($0.assetFile)`.")
            }
        }
    }

    private func updateGeoEntities(currentDeviceLocation: DeviceLocation,
                                   currentDeviceTranslation: SIMD3<Float>,
                                   assets: [ModelAsset]) {
        let deviceLoc = LocationUtility.Location(latitude: currentDeviceLocation.latitude,
                         longitude: currentDeviceLocation.longitude,
                         altitude: currentDeviceLocation.altitude)

        // remove distance away objects
        var removingEntities: [UUID] = []
        geoEntities.forEach {
            let entityLoc = LocationUtility.Location(latitude: $0.latitude,
                                                     longitude: $0.longitude,
                                                     altitude: $0.altitude)
            if LocationUtility.distance(deviceLoc, from: entityLoc) >= $0.distanceAway {
                removingEntities.append($0.id)
                $0.entity.removeFromParent()
            }
        }
        if !removingEntities.isEmpty {
            geoEntities = geoEntities.filter { geoEntity in
                !removingEntities.contains(where: { $0 == geoEntity.id })
            }
        }

        // update each virtual object's virtual location
        geoEntities.forEach {
            let entityLoc = LocationUtility.Location(latitude: $0.latitude,
                                                     longitude: $0.longitude,
                                                     altitude: $0.altitude)
            let diffXYZ = LocationUtility.locationDiff(base: deviceLoc,
                                                           from: entityLoc)
            let entityTranslation = currentDeviceTranslation + diffXYZ
            $0.entity.transform.translation = entityTranslation
        }

        // add assets
        let addingAssets = assets.filter({ asset in
            if geoEntities.contains(where: { $0.id == asset.id }) { return false }
            let assetLoc = LocationUtility.Location(latitude: asset.latitude,
                                                    longitude: asset.longitude,
                                                    altitude: asset.altitude)
            return LocationUtility.distance(deviceLoc,
                                      from: assetLoc) < asset.approachingDistance
        })

        if !addingAssets.isEmpty {
            addGeoEntities(deviceTranslation: currentDeviceTranslation,
                           deviceLoc: deviceLoc,
                           addingAssets: addingAssets)
        }
    }
}

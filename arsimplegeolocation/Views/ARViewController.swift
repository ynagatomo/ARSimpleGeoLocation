//
//  ARViewController.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import UIKit
import ARKit
import RealityKit

final class ARViewController: UIViewController {
    private var arView: ARView!
    private var arScene: ARScene!

    static var isPeopeOcclusionSupported: Bool {
        ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)
    }
    static var isObjectOcclusionSupported: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    //    init() {
    //        super.init(nibName: nil, bundle: nil)
    //    }
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if targetEnvironment(simulator)
        arView = ARView(frame: .zero)
        #else
        if ProcessInfo.processInfo.isiOSAppOnMac {
            arView = ARView(frame: .zero, cameraMode: .nonAR,
                            automaticallyConfigureSession: true)
        } else {
            // automaticallyConfigureSession = true is Ok
            // for scene reconstruction for mesh
            arView = ARView(frame: .zero, cameraMode: .ar,
                            automaticallyConfigureSession: true)
        }
        #endif
        arView.session.delegate = self

        #if DEBUG
        arView.debugOptions = []
        #endif
        view = arView

        let anchorEntity = AnchorEntity(world: .zero)
        arView.scene.addAnchor(anchorEntity)
        arScene = ARScene(arView: arView, anchor: anchorEntity)
        arScene.setupScene()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if !targetEnvironment(simulator)
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            let config = ARWorldTrackingConfiguration()
            if AppSettings.share.enablePlaneDetection { // Plane detection
                config.planeDetection = [.horizontal]
                debugLog("AR: plane detection was enabled.")
            }
            config.worldAlignment = .gravityAndHeading // -Z is heading to north
            if AppSettings.share.enablePeopleOcclusion { // People occlusion
                if ARViewController.isPeopeOcclusionSupported {
                    config.frameSemantics.insert(.personSegmentationWithDepth)
                    debugLog("AR: people occlusion was enabled.")
                }
            }
            // [Note]
            // When you enable scene reconstruction, ARKit provides a polygonal mesh
            // that estimates the shape of the physical environment.
            // If you enable plane detection, ARKit applies that information to the mesh.
            // Where the LiDAR scanner may produce a slightly uneven mesh on a real-world surface,
            // ARKit smooths out the mesh where it detects a plane on that surface.
            // If you enable people occlusion, ARKit adjusts the mesh according to any people
            // it detects in the camera feed. ARKit removes any part of the scene mesh that
            // overlaps with people
            if AppSettings.share.enableObjectOcclusion { // Object occlusion
                if ARViewController.isObjectOcclusionSupported {
                    // Enable the object occlusion
                    config.sceneReconstruction = .mesh
                    arView.environment.sceneUnderstanding.options.insert(.occlusion)
                    debugLog("AR: object occlusion was enabled.")
                }
            }
            arView.session.run(config)
        }
        #endif

        arScene.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arScene.stopSession()
        #if !targetEnvironment(simulator)
        arView.session.pause()
        #endif
    }
}

extension ARViewController {
    func setup(device: DeviceLocation?, assets: [ModelAsset]) {
        // do nothing so far
    }

    func update(device: DeviceLocation?, assets: [ModelAsset]) {
        arScene.updateLocation(device: device, assets: assets)
    }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    //    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    //        debugLog("session(_:didAdd:) was called.")
    //    }
    //
    //    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    //        debugLog("session(_:didUpdate:) was called.")
    //    }
    //
    //    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    //        debugLog("session(_:didRemove:) was called.")
    //    }

    //    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    //        // You can get the camera's (device's) position in the virtual space
    //        // from the transform property.
    //        // The 4th column represents the position, (x, y, z, -).
    //        let cameraTransform = frame.camera.transform
    //        // The orientation of the camera, expressed as roll, pitch, and yaw values.
    //        let cameraEulerAngles = frame.camera.eulerAngles // simd_float3
    //    }

    func sessionWasInterrupted(_ session: ARSession) {
        debugLog("sessionWasInterrupted(_:) was called.")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        debugLog("sessionInterruptionEnded(_:) was called.")
    }

    // Camera un-authorization error should be handled
    func session(_ session: ARSession, didFailWithError error: Error) {
        debugLog("session(_:didFailWithError) was called. error = \(error.localizedDescription)")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        debugLog("session(_:cameraDidChangeTrackingState:) was called. camera = \(camera)")
    }
}

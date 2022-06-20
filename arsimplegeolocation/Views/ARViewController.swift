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
            config.worldAlignment = .gravityAndHeading // -Z is heading to north
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                debugLog("ARSession: personSegmentationWithDepth is supported.")
                config.frameSemantics.insert(.personSegmentationWithDepth)
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
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        debugLog("session(_:didAdd:) was called.")
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        debugLog("session(_:didUpdate:) was called.")
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        debugLog("session(_:didRemove:) was called.")
    }

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

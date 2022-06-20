//
//  ARContainerView.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import SwiftUI

struct ARContainerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    let deviceLocation: DeviceLocation?
    let modelAssets: [ModelAsset]

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ARViewController {
        let arViewController = ARViewController()
        arViewController.setup(device: deviceLocation, assets: modelAssets)
        return arViewController
    }

    func updateUIViewController(_ uiViewController: ARViewController,
                                context: Context) {
        uiViewController.update(device: deviceLocation, assets: modelAssets)
    }

    class Coordinator: NSObject {
        var parent: ARContainerView
        init(_ parent: ARContainerView) {
            self.parent = parent
        }
    }
}

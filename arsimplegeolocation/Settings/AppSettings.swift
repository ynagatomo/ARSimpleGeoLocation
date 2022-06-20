//
//  AppSettings.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/20.
//

import SwiftUI

class AppSettings {
    static let share = AppSettings()
    private init() {}
    // Defaults
    static let showingCoordinateDefault = true
    static let distanceFilterDefault: Double = 3.0 // [m]

    // Privacy
    @AppStorage("showingCoordinate") var showingCoordinateOfDevice = showingCoordinateDefault

    // DistanceFilter for Location Services
    let filterDistances: [Double] = [0.0, 1.0, 3.0, 5.0, 10.0, 30.0, 50.0]
    @AppStorage("distanceFilter") var distanceFilter: Double = distanceFilterDefault
}

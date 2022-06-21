//
//  AppStateController.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import CoreLocation

struct LocationCapabilities {
    // true if significant location change monitoring is available
    //     This capability provides tremendous power savings for apps that want
    //     to track a user’s approximate location and don’t need highly accurate
    //     position information.
    let significantLocationMonitoringAvailable: Bool

    // true if heading data is available
    //     You should check the value returned by this method before asking
    //     the location manager to deliver heading-related events
    let headingAvailable: Bool
}

@MainActor
class AppStateController: NSObject, ObservableObject {
    // Location Manager
    let locationManager = CLLocationManager()
    let locationCapabilities: LocationCapabilities
    enum UpdatingLocationState: Int { case updating = 0, stop }
    var updatingLocationState = UpdatingLocationState.stop

    // Location Service Authorization by a user
    @Published var locationServicesAuthorized = false
    enum LocationServiceAccuracyAuthorization: Int {
        case fullyAccuracy = 0, reducedAccuracy
    }
    var accuracyAuthorization = LocationServiceAccuracyAuthorization.reducedAccuracy // accuracy

    // Device location
    @Published var deviceLocation: DeviceLocation?
    var lastLocation: CLLocation?

    // Model Assets
    let modelAssets = ModelDataSet.dataSet

    override init() {
        locationCapabilities = Self.checkLocationCapabilities()
        super.init()
        locationManager.delegate = self
    }

    func clearDeviceLocation() {
        deviceLocation = nil
        lastLocation = nil
    }
}

extension AppStateController {
    // you can invoke this function in the setting view. do whatever you want
    func doSomething() {
    }
}

// MARK: - LocationManager

extension AppStateController {
    private static func checkLocationCapabilities() -> LocationCapabilities {
        let capability1 = CLLocationManager.significantLocationChangeMonitoringAvailable()

        let capability2 = CLLocationManager.headingAvailable()
        return LocationCapabilities(significantLocationMonitoringAvailable: capability1,
                                    headingAvailable: capability2)
    }

    // Request the location service authorization
    //
    // [Note] You must call this method or requestAlwaysAuthorization()
    //     before you can receive location-related information.
    //     You may call requestWhenInUseAuthorization() whenever the current
    //     authorization status is not determined (CLAuthorizationStatus.notDetermined).
    // [Note] This method runs asynchronously and prompts the user to grant permission
    //     to the app to use location services. The user prompt contains the text from
    //     the NSLocationWhenInUseUsageDescription key in your app Info.plist file,
    //     and the presence of that key is required when calling this method.
    func requestAuthorization() {
        debugLog("requestAuthorization for When In Use was called.")
        locationManager.requestWhenInUseAuthorization()
    }

    // Start the location services
    func startUpdatingLocation() {
        debugLog("startUpdatingLocation() was called.")
        assert(updatingLocationState == .stop)
        updatingLocationState = .updating
        clearDeviceLocation()

        #if !targetEnvironment(simulator)
        // [Note] For iOS, the default value of this property is kCLLocationAccuracyBest.
        // assert(locationManager.desiredAccuracy == kCLLocationAccuracyBest)

        // [Note] The default value (Double [m]) of this property is
        //        kCLDistanceFilterNone.
        //
        // assert(locationManager.distanceFilter == kCLDistanceFilterNone)
        if AppSettings.share.distanceFilter != 0 {
            locationManager.distanceFilter = AppSettings.share.distanceFilter // [m]
        }

        // [Note] On supported platforms the default value of this property is true
        // assert(locationManager.pausesLocationUpdatesAutomatically == true)
        #endif

        // [Note]
        //    The default value of this property is CLActivityType.other.
        //    fitness: The location manager is being used to track fitness activities
        //    such as walking, running, cycling, and so on.
        //    when the value of activityType is CLActivityType.fitness,
        //    indoor positioning is disabled.
        // locationManager.activityType = .fitness

        // [Note] This method returns immediately. Calling this method causes
        //    the location manager to obtain an initial location fix (which may
        //    take several seconds) and notify your delegate by calling its
        //    locationManager(_:didUpdateLocations:) method.
        //    If you start this service and your app is suspended,
        //    the system stops the delivery of events until your app starts
        //    running again (either in the foreground or background).
        locationManager.startUpdatingLocation()
    }

    // Stop the location services
    func stopUpdatingLocation() {
        debugLog("stopUpdatingLocation() was called.")
        if updatingLocationState == .updating {
            updatingLocationState = .stop
            locationManager.stopUpdatingLocation()
            clearDeviceLocation()
        }
    }
}

// MARK: - CLLocationManager Delegate

extension AppStateController: CLLocationManagerDelegate {

    // [Note] If the user’s choice doesn’t change the authorization status
    //     after you call the requestWhenInUseAuthorization() or requestAlwaysAuthorization()
    //     method, the location manager doesn’t report the current authorization status to
    //     this method—the location manager only reports changes.
    //
    // [Note] An app's authorization status changes in response to users’ actions.
    //     Users can change permission for apps to use location information at any time.
    //     The user can:
    //     - Change an app’s location authorization in Settings > Privacy > Location Services,
    //       or in Settings > (the app) > Location Services.
    //     - Turn location services on or off globally in Settings > Privacy > Location Services.
    //     - Choose Reset Location & Privacy in Settings > General > Reset.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Tells the delegate when the app creates the location manager
        // and when the authorization status changes.
        debugLog("locationManagerDidChangeAuthorization(_:) was called.")

        var authorized = false
        switch manager.authorizationStatus {
        case .notDetermined,
             // The user has not chosen whether the app can use location services
             .restricted,
             // The app is not authorized to use location services
             .denied:
             // The user denied the use of location services for the app or they are disabled globally in Settings.
            authorized = false
        case .authorizedAlways,
            // The user authorized the app to start location services at any time
             .authorizedWhenInUse:
            // The user authorized the app to start location services while it is in use
            authorized = true
        @unknown default:
            fatalError("Unknown authorization status.")
        }
        locationServicesAuthorized = authorized

        var accuracy: LocationServiceAccuracyAuthorization
        switch manager.accuracyAuthorization {
        case .fullAccuracy:
            // The user authorized the app to access location data with full accuracy
            accuracy = .fullyAccuracy
        case .reducedAccuracy:
            // The user authorized the app to access location data with reduced accuracy
            accuracy = .reducedAccuracy
        @unknown default:
            fatalError("Unknown accuracy level.")
        }
        accuracyAuthorization = accuracy
        debugLog(" - authorized = \(authorized ? "Yes" : "No")")
        debugLog(" - accuracy = \(accuracy == .fullyAccuracy ? "Fully" : "Reduced")")
    }

    // MARK: Handling Errors

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Tells the delegate that the location manager was unable to retrieve a location value.
        debugLog("locationManager(_:didFailWithError) was called. error = \(error.localizedDescription)")
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            stopUpdatingLocation()
            return
        }
    }

    // MARK: Responding to Location Events

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Tells the delegate that new location data is available
        debugLog("locationManager(_:didUpdateLocations) was called.")
        guard let location = locations.last else { return }

        // update the device location
        if let newLocation = makeDeviceLocation(location: location) {
            deviceLocation = newLocation
            lastLocation = location // keep the CLLocation object
        }
    }

    private func makeDeviceLocation(location: CLLocation) -> DeviceLocation? {
        // A negative value of horizontalAccuracy indicates that
        // the latitude and longitude are invalid.
        guard location.horizontalAccuracy >= 0 else { return nil }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let horizontalAccuracy = location.horizontalAccuracy

        var altitude: Double?
        // If verticalAccuracy is 0 or a negative value, altitude is invalid.
        if location.verticalAccuracy > 0 {
            altitude = location.altitude
        }
        let verticalAccuracy = location.verticalAccuracy

        let floor = location.floor?.level
        let timestamp = location.timestamp

        return DeviceLocation(latitude: latitude,
                              longitude: longitude,
                              altitude: altitude,
                              floor: floor,
                              horizontalAccuracy: horizontalAccuracy,
                              verticalAccuracy: verticalAccuracy,
                              timestamp: timestamp)
    }

    //    func locationManager(_ manager: CLLocationManager, didUpdateTo: CLLocation, from: CLLocation) {
    //        // Tells the delegate that a new location value is available
    //    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Tells the delegate that updates will no longer be deferred
        // swiftlint:disable line_length
        debugLog("locationManager(_:didFinishDeferredUpdatesWithError) was called. error = \(error?.localizedDescription ?? "")")
    }

    // MARK: Pausing Location Updates

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        // Tells the delegate that location updates were paused
        debugLog("locationManagerDidPauseLocationUpdates(_:) was called.")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        // Tells the delegate that the delivery of location updates has resumed
        debugLog("locationManagerDidResumeLocationUpdates(_:) was called.")
    }

    // MARK: Responding to Heading Events

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Tells the delegate that the location manager received updated heading information.
        debugLog("locationManager(_:didUpdateHeading) was called.")
    }

    //    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    //        // Asks the delegate whether the heading calibration alert should be displayed
    //        return true
    //    }

    // MARK: Responding to Region Events

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Tells the delegate that the user entered the specified region
        debugLog("locationManager(_:didEnterRegion) was called.")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Tells the delegate that the user left the specified region
        debugLog("locationManager(_:didExitRegion) was called.")
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // Tells the delegate about the state of the specified region
        debugLog("locationManager(_:didDetermineState:for:) was called.")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // Tells the delegate that a region monitoring error occurred
        debugLog("locationManager(_:monitoringDidFailFor:withError:) was called. error = \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // Tells the delegate that a new region is being monitored
        debugLog("locationManager(_:didStartMonitoringFor:) was called.")
    }

    // MARK: Responding to Visit Events

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // Tells the delegate that a new visit-related event was received
        debugLog("locationManager(_:didVisit:) was called.")
    }
}

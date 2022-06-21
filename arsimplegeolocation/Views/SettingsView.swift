//
//  SettingsView.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let appState: AppStateController
    @State private var distanceFilter = AppSettings.share.distanceFilter
    @State private var showingCoordinate = AppSettings.share.showingCoordinateOfDevice
    @State private var enablePlaneDetection = AppSettings.share.enablePlaneDetection
    @State private var enablePeopleOcclusion = AppSettings.share.enablePeopleOcclusion
    @State private var enableObjectOcclusion = AppSettings.share.enableObjectOcclusion

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                        .padding(.horizontal, 40)
                }
            }

            Text("Settings")
                .font(.largeTitle)
            List {
                // Debug
                Section(content: {
                    HStack {
                        Spacer()
                        Button(action: { appState.doSomething() }, label: {
                            Text("Do Something")
                        })
                        .buttonStyle(.borderedProminent)
                    } // HStack
                }, header: { Text("Development") })
                // App State
                Section(content: {
                    Text("Location Service authorized: " + (appState.locationServicesAuthorized ? "Yes" : "No"))
                    Text("Accuracy authorization for " +
                         (appState.accuracyAuthorization == .fullyAccuracy ? "Fully" : "Reduced"))
                }, header: { Text("App State") })

                // Privacy settings
                Section(content: {
                    Toggle("Show coordinate", isOn: $showingCoordinate)
                        .onChange(of: showingCoordinate) { value in
                            AppSettings.share.showingCoordinateOfDevice = value
                        }
                }, header: { Text("Privacy") })

                // Location Services settings
                Section(content: {
                    HStack {
                        Text("Distance Filter: ")
                        Spacer()
                        Picker(selection: $distanceFilter,
                               label: Text("distance [meters]")) {
                            ForEach(AppSettings.share.filterDistances, id: \.self) {
                                Text(String($0))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: distanceFilter) { value in
                            AppSettings.share.distanceFilter = value
                        }
                    } // HStack
                }, header: { Text("Location Services") })

                // AR capabilities
                Section(content: {
                    Toggle("Enable plane detection", isOn: $enablePlaneDetection)
                        .onChange(of: enablePlaneDetection) { value in
                            AppSettings.share.enablePlaneDetection = value
                        }
                    Toggle("Enable people occlusion", isOn: $enablePeopleOcclusion)
                        .onChange(of: enablePeopleOcclusion) { value in
                            AppSettings.share.enablePeopleOcclusion = value
                        }
                        .disabled(!ARViewController.isPeopeOcclusionSupported)
                    Toggle("Enable object occlusion", isOn: $enableObjectOcclusion)
                        .onChange(of: enableObjectOcclusion) { value in
                            AppSettings.share.enableObjectOcclusion = value
                        }
                        .disabled(!ARViewController.isObjectOcclusionSupported)
                }, header: { Text("AR Capabilities") })

                // Assets
                Section(content: {
                    ForEach(appState.modelAssets) { asset in
                        HStack {
                            if let name = asset.thumbnailFile {
                                Image(name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            } else {
                                Color.gray
                                    .frame(width: 80, height: 80)
                            }
                            VStack(alignment: .leading) {
                                Text(asset.name)
                                Text("- latitude: "
                                     + coordinateString(asset.latitude) + " [degrees]"
                                ).font(.caption).foregroundColor(.secondary)
                                Text("- longitude: "
                                     + coordinateString(asset.longitude) + " [degrees]"
                                ).font(.caption).foregroundColor(.secondary)
                                Text("- altitude: "
                                     + coordinateString(asset.altitude, format: "%4.2f") + "[m]"
                                ).font(.caption).foregroundColor(.secondary)
                                Text("- approach: \(Int(asset.approachingDistance))[m] "
                                     + "away: \(Int(asset.distanceAway))[m]"
                                ).font(.caption).foregroundColor(.secondary)
                            } // VStack
                            .padding(.horizontal)
                        } // HStack
                    } // ForEach
                }, header: { Text("Assets") })
            } // List
            .listStyle(SidebarListStyle())
        } // VStack
    } // body

    private func coordinateString(_ value: Double, format: String = "%4.6f") -> String {
        var string = "****.**"
        if showingCoordinate {
            string = String(format: format, value)
        }
        return string
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(appState: AppStateController())
    }
}

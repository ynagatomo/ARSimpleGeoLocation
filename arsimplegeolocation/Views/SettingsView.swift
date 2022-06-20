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
                    Toggle("Showing coordinate", isOn: $showingCoordinate)
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

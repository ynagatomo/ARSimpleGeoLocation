//
//  HomeView.swift
//  arsimplegeolocation
//
//  Created by Yasuhito Nagatomo on 2022/06/18.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var appStateController = AppStateController()
    @State private var isShowingAR = false
    @State private var isShowingSettings = false

    var body: some View {
        ZStack {
            Color("HomeBGColor").ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: { isShowingSettings = true },
                           label: {
                            Image(systemName: "gearshape")
                                .font(.largeTitle)
                                .padding(.horizontal, 40)
                            })
                }
                Spacer()
                Group {
                    Image(systemName: "location.viewfinder")
                        .font(.system(size: 40))
                        .padding()
                    Text("AR Simple GeoLocation")
                        .font(.title2)
                }
                .foregroundColor(.white)

                Spacer()

                Button("Begin", action: {
                    isShowingAR = true
                })
                .buttonStyle(.borderedProminent)
                .padding(40)
                .disabled(!appStateController.locationServicesAuthorized)
            } // VStack
        } // ZStack
        .controlSize(.large)
        .onAppear {
            appStateController.requestAuthorization()
        }
        .fullScreenCover(isPresented: $isShowingAR) {
            ARLocationView(appStateController: appStateController)
        }
        .fullScreenCover(isPresented: $isShowingSettings) {
            SettingsView(appState: appStateController)
        }
    } // body
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

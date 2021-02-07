//
//  TCAFirstTryApp.swift
//  TCAFirstTry
//
//  Created by Roman Misnikov on 06.02.2021.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAFirstTryApp: App {

    @StateObject var module = SettingsModule()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SettingsScreen(settingStore: module.store)
            }
        }
    }
}

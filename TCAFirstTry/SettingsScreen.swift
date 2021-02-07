//
//  SettingsScreen.swift
//  TCAFirstTry
//
//  Created by Roman Misnikov on 06.02.2021.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Business logic

class SettingsModule: ObservableObject {

    // State variables
    enum State: Equatable {
        case isLoading
        case settings([Setting])
    }

    // User actions and callbacks
    enum Action {
        case initial
        case didLoadSettings([Setting])
    }

    // Dependencies
    struct Environment {
        let settingsService: ISettingsService
    }

    // MARK: - Variables
    lazy var store = Store(initialState: state, reducer: reducer, environment: environment)

    let state = State.isLoading
    let environment = Environment(settingsService: SettingsServiceMock())
    let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .initial:
            return environment.settingsService
                .getSettings()
                .map { .didLoadSettings($0) }
                .eraseToEffect()
        case .didLoadSettings(let settings):
            state = .settings(settings)
            return .none
        }
    }.debug()

    let reducer2 = Reducer<State, Action, Environment>.combine(

    )
}

// MARK: - View

struct SettingsScreen: View {

    var settingStore: Store<SettingsModule.State, SettingsModule.Action>

    var body: some View {
        WithViewStore(settingStore) { viewStore in
            Group {
                switch viewStore.state {
                case .isLoading:
                    ProgressView()
                        .scaleEffect(x: 2, y: 2)
                case .settings(let settings):
                    List {
                        ForEach(settings) { setting in
                            SettingCell(store: SingleSettingModule(setting: setting).store)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .onAppear { viewStore.send(.initial) }
        }
        .navigationBarTitle("Рекламные рассылки", displayMode: .inline)
    }
}

// MARK: - Previews

struct SettingsScreen_Previews: PreviewProvider {

    static var module = SettingsModule()
    static var previews: some View {
        NavigationView {
            SettingsScreen(settingStore: module.store)
        }
        .environment(\.colorScheme, .dark)
    }
}

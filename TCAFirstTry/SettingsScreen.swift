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
    struct State: Equatable {
        var isLoading = true
        var settings = [Setting]()
    }

    // User actions and callbacks
    enum Action {
        // user actions
        case initial
        case toggleSwitch(index: Int, action: SingleSettingModule.Action)
        // callbacks actions
        case didLoadSettings(settings: [Setting])
        case didUpdateSettings
    }

    // Dependencies
    struct Environment {
        let settingsService: ISettingsService
    }
    
    // MARK: - Submodules
    // ???
    
    // MARK: - Variables
    lazy var store = Store(initialState: state, reducer: screenReducer, environment: environment)
    
    let state = State()
    let environment = Environment(settingsService: SettingsServiceMock())
    lazy var screenReducer = Reducer<State, Action, Environment>.combine(
        singleSettingReducer.forEach(
            state: \.settings,
            action: /Action.toggleSwitch(index:action:),
            environment: { SingleSettingModule.Environment(settingsService: $0.settingsService) }),
        Reducer { state, action, environment in
            switch action {
            case .initial:
                return environment.settingsService
                    .getSettings()
                    .map { .didLoadSettings(settings: $0) }
                    .eraseToEffect()
            case .didLoadSettings(let settings):
                state.isLoading = false
                state.settings = settings
                return .none
            case .toggleSwitch(let index, let action):
                return environment.settingsService.update(setting: state.settings[index])
                    .map { _ in .didUpdateSettings }
                    .eraseToEffect()
            case .didUpdateSettings:
                return .none
            }
        }
    )
    .debug()

    let singleSettingReducer = Reducer<Setting, SingleSettingModule.Action, SingleSettingModule.Environment> { state, action, environment in
        switch action {
        case .toggleSwitch:
            state.isEnabled.toggle()
            return environment.settingsService.update(setting: state)
                .map { _ in .didUpdateSetting }
                .eraseToEffect()
        case .didUpdateSetting:
            return .none
        }
    }
}

// MARK: - View

struct SettingsScreen: View {

    var settingStore: Store<SettingsModule.State, SettingsModule.Action>

    var body: some View {
        WithViewStore(settingStore) { viewStore in
            Group {
                if viewStore.state.isLoading {
                    ProgressView().scaleEffect(x: 2, y: 2)
                } else {
                    List {
//                        ForEach(viewStore.state.settings) { setting in
//                            SettingCell(store: SingleSettingModule(setting: setting).store)
//                        }
                        ForEachStore(settingStore.scope(state: \.settings, action: SettingsModule.Action.toggleSwitch(index:action:))) {
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

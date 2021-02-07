//
//  SettingCell.swift
//  TCAFirstTry
//
//  Created by Roman Misnikov on 06.02.2021.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Business logic

class SingleSettingModule {

    // State variables
    struct State: Equatable {
        var setting: Setting
        var isBlocked = false
    }

    // User actions and callbacks
    enum Action {
        case toggleSwitch
        case didUpdateSetting
    }

    // Dependencies
    struct Environment {
        let settingsService: ISettingsService
    }

    // MARK: Variables
    let setting: Setting

    lazy var store = Store(initialState: state, reducer: reducer, environment: environment)
    lazy var state = State(setting: setting)
    let environment = Environment(settingsService: SettingsServiceMock())

    lazy var reducer = Reducer<State, Action, Environment>  { [weak self] state, action, environment in
        switch action {
        case .toggleSwitch:
            state.setting.isEnabled.toggle()
            state.isBlocked = true
            return self?.update(setting: state.setting) ?? .none
        case .didUpdateSetting:
            state.isBlocked = false
            return .none
        }
    }.debug()

    // MARK: Init
    init(setting: Setting) {
        self.setting = setting
    }

    private func update(setting: Setting) -> Effect<Action, Never> {
        environment.settingsService
            .update(setting: setting)
            .map { _ in .didUpdateSetting }
            .eraseToEffect()
    }
}

// MARK: - View

struct SettingCell: View {

    var store: Store<SingleSettingModule.State, SingleSettingModule.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            Toggle(
                isOn: viewStore.binding(
                    get: { $0.setting.isEnabled },
                    send: .toggleSwitch)) {
                Text(viewStore.state.setting.name)
            }
            .disabled(viewStore.state.isBlocked)
            .padding(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
//            .background(color(state: viewStore.state))
        }
    }

    func color(state: SingleSettingModule.State) -> Color {
        state.setting.isEnabled
            ? Color(.systemGreen).opacity(0.1)
            : Color(.systemGray).opacity(0.5)
    }
}

// MARK: - Previews

struct SettingCell_Previews: PreviewProvider {

    static var module = SingleSettingModule(setting: Setting(name: "Testing cell parameter", isEnabled: true))

    static var previews: some View {
        SettingCell(store: module.store)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

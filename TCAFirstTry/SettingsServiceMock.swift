//
//  SettingsService.swift
//  TCAFirstTry
//
//  Created by Roman Misnikov on 06.02.2021.
//

import Foundation
import Combine
import Dispatch

struct Setting: Equatable, Identifiable {
    let id: UUID = UUID()
    let name: String
    var isEnabled: Bool
}

protocol ISettingsService {
    func getSettings() -> AnyPublisher<[Setting], Never>
    func update(setting: Setting) -> AnyPublisher<Bool, Never>
}

class SettingsServiceMock: ISettingsService {

    private var settingsStore = [
        Setting(name: "Получать рекламные рассылки раздела \"Покупки\"", isEnabled: false),
        Setting(name: "Получать Push-сообщения с предложениями Yota", isEnabled: false),
    ]

    func getSettings() -> AnyPublisher<[Setting], Never> {
        Just(settingsStore)
            .delay(for: 3, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func update(setting: Setting) -> AnyPublisher<Bool, Never> {
        Just(true)
            .delay(for: 2, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

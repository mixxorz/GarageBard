//
//  UpdaterViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/20/22.
//

import Foundation
import Sparkle

// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked
final class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    @Published var canCheckForUpdates = false

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

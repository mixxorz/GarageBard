//
//  GarageBardApp.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/4/22.
//

import SwiftUI

@main
struct GarageBardApp: App {
    @ObservedObject var playerViewModel = PlayerViewModel()
    @StateObject var updaterViewModel = UpdaterViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView<PlayerViewModel>()
                .environment(\.colorScheme, .dark)
                .environmentObject(playerViewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updaterViewModel: updaterViewModel)
            }
        }
    }
}

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

    var body: some Scene {
        WindowGroup {
            ContentView<PlayerViewModel>()
                .environment(\.colorScheme, .dark)
                .environmentObject(playerViewModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

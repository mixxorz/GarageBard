//
//  CheckForUpdatesView.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/20/22.
//

import Foundation
import SwiftUI

struct CheckForUpdatesView: View {
    @ObservedObject var updaterViewModel: UpdaterViewModel

    var body: some View {
        Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
            .disabled(!updaterViewModel.canCheckForUpdates)
    }
}

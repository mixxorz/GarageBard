//
//  Notifications.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import SwiftUI

struct Notifications<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.controlActiveState) var controlActiveState

    var body: some View {
        VStack {
            Spacer()

            if let track = vm.track {
                if track.hasOutOfRangeNotes {
                    Toast(image: Image(systemName: "music.quarternote.3")) {
                        Text("Some notes are out of range.")
                        if vm.notesTransposed {
                            Text("The current track has notes that fall beyond playable range. These notes will be automatically transposed to fit within the playable range.")
                                .font(.system(size: 12.0))
                                .foregroundColor(Color("grey400"))
                        } else {
                            Text("The current track has notes that fall beyond playable range. These notes will be skipped.")
                                .font(.system(size: 12.0))
                                .foregroundColor(Color("grey400"))
                        }
                    }
                }
            }

            if !vm.foundXIVprocess {
                Toast(image: Image(systemName: "gamecontroller")) {
                    Text("Can't find game instance. Is the game running?")
                    Text("When you play a song, keystrokes will be sent to the frontmost window instead.")
                        .font(.system(size: 12.0))
                        .foregroundColor(Color("grey400"))
                }
            }

            if !vm.hasAccessibilityPermissions {
                Toast(image: Image(systemName: "gear")) {
                    Text("GarageBard needs Accessibility access in order to send keystrokes to Final Fantasy XIV.")
                    Text("Tap to open macOS Accessibility preferences.")
                        .font(.system(size: 12.0))
                        .foregroundColor(Color("grey400"))
                }
                .onTapGesture {
                    vm.checkAccessibilityPermissions(prompt: true)
                }
            }
        }
        .padding(space(4))
        .onChange(of: controlActiveState) { state in
            // Disable this code in preview mode
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                if state == .key || state == .active {
                    vm.checkAccessibilityPermissions(prompt: false)
                    vm.findXIVProcess()
                }
            }
        }
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications<FakePlayerViewModel>()
            .environmentObject(
                FakePlayerViewModel(
                    hasAccessibilityPermissions: false,
                    foundXIVprocess: false
                )
            )
            .frame(width: space(100))
            .background(Color("grey700"))
    }
}

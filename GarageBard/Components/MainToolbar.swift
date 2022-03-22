//
//  MainToolbar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/18/22.
//

import SwiftUI

struct MainToolbar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    @State var isTrackPopoverOpen = false
    @State var isSettingsPopoverOpen = false
    @Binding var isSubToolbarOpen: Bool

    var body: some View {
        ZStack {
            HStack {
                PlayerButton(action: { self.isTrackPopoverOpen = true }, iconName: "pianokeys")
                    .popover(
                        isPresented: $isTrackPopoverOpen,
                        arrowEdge: .bottom,
                        content: {
                            TrackPopover<ViewModel>(tracks: vm.song?.tracks ?? [])
                        }
                    )
                    .help("Tracks")
                PlayerButton(action: {
                    withAnimation(.spring()) {
                        self.isSubToolbarOpen.toggle()
                    }
                }, iconName: "dial.max")
                    .help("Effects")
                Spacer()
            }
            HStack(spacing: space(2)) {
                PlayerButton(action: vm.playOrPause, iconName: vm.isPlaying ? "pause.fill" : "play.fill")
                    .help(vm.isPlaying ? "Pause" : "Play")
                    .keyboardShortcut(.space, modifiers: [])
                PlayerButton(action: vm.stop, iconName: "stop.fill")
                    .help("Stop")
            }
            HStack {
                Spacer()
                PlayerButton(action: vm.openLoadSongDialog, iconName: "folder.badge.plus")
                    .help("Add song")
                PlayerButton(action: { self.isSettingsPopoverOpen = true }, iconName: "ellipsis")
                    .popover(
                        isPresented: $isSettingsPopoverOpen,
                        arrowEdge: .bottom,
                        content: {
                            PopoverMenu {
                                // Play mode
                                PopoverMenuItem(action: {
                                    withAnimation(.spring()) {
                                        vm.playMode = .perform
                                    }

                                }) {
                                    Text("Perform")
                                    Spacer()
                                    if vm.playMode == .perform {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .help("Send keystrokes to the game")
                                PopoverMenuItem(action: {
                                    withAnimation(.spring()) {
                                        vm.playMode = .listen
                                    }

                                }) {
                                    Text("Listen")
                                    Spacer()
                                    if vm.playMode == .listen {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .help("Listen to the song with GarageBard's synthesizer")

                                // Loop
                                Divider()
                                    .padding(.vertical, space(1))
                                PopoverMenuItem(action: {
                                    if vm.loopMode == .off {
                                        vm.loopMode = .song
                                    } else {
                                        vm.loopMode = .off
                                    }
                                }) {
                                    Text("Loop song")
                                    Spacer()
                                    if vm.loopMode == .song {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .help("Plays the current song in a loop")

                                // Continuous playback
                                Divider()
                                    .padding(.vertical, space(1))
                                PopoverMenuItem(action: {
                                    vm.continuousPlayback.toggle()
                                }) {
                                    Text("Continuous playback")
                                    Spacer()
                                    if vm.continuousPlayback {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .help("Plays the next song after the current one finishes")
                            }
                        }
                    )
                    .help("Settings")
            }
        }
        .padding(.vertical, space(2))
    }
}

struct MainToolbar_Previews: PreviewProvider {
    static var previews: some View {
        MainToolbar<FakePlayerViewModel>(isSubToolbarOpen: .constant(false))
            .environmentObject(FakePlayerViewModel())
            .frame(width: space(100))
            .background(Color("grey600"))
    }
}

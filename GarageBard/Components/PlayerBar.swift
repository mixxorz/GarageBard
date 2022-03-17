//
//  PlayerBar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct PlayerButton: View {
    var action: () -> Void
    var iconName: String

    @State var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .frame(width: space(8), height: space(6))
                    .foregroundColor(.white)
                    .opacity(isHovering ? 0.1 : 0)
                Image(systemName: iconName)
                    .font(.system(size: 20.0))
                    .foregroundColor(Color("grey400"))
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct MainToolbar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    @State var isTrackPopoverOpen = false
    @State var isSettingsPopoverOpen = false

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
                            }
                        }
                    )
                    .help("Settings")
            }
        }
        .padding(.vertical, space(2))
    }
}

struct InputField: View {
    var name: String
    var value: String

    @FocusState var isFocused: Bool
    @State var tempValue: String = "TEST"
    @State var bufferValue: String = ""

    private func setValue() {
        if bufferValue != "" {
            tempValue = bufferValue
        }
        bufferValue = ""
        isFocused = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: space(1)) {
            Text(name)
                .font(.system(size: 12.0))
            ZStack {
                Rectangle()
                    .foregroundColor(Color("grey700"))
                    .frame(width: space(20), height: space(5))
                    .border(isFocused ? Color.orange : Color("grey500"), width: 1)
                    .onTapGesture {
                        isFocused = true
                    }

                TextField("", text: $bufferValue)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
                    .opacity(bufferValue != "" ? 1 : 0)
                    .frame(width: space(20), height: space(5))
                    .onSubmit(setValue)
                    .focused($isFocused)
                    .onChange(of: isFocused, perform: { focused in
                        if !focused {
                            setValue()
                        }
                    })

                if bufferValue == "" {
                    Text(tempValue)
                        .font(.system(size: 10.0))
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

struct SubToolbar: View {
    @State var text: String = "1.0"

    var body: some View {
        HStack {
            InputField(name: "Tempo", value: "120-216 BPM")
            InputField(name: "Tranpose", value: "C2-D#2 +99")
            Spacer()
        }
    }
}

struct PlayerBar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    let formatter = TimeFormatter.instance

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(vm.currentProgress > 0 ? formatter.format(vm.currentPosition) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(16), alignment: .leading)
                Spacer()
                Text(vm.song?.name ?? "No song selected")
                    .font(.system(size: 14.0))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                Text(vm.currentProgress > 0 ? formatter.format(vm.timeLeft) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(16), alignment: .trailing)
            }
            ProgressBar(value: vm.currentProgress)
                .frame(height: space(1))
                .onSeek(seekAction: { percentage in
                    vm.seek(progress: percentage, end: false)
                }, seekEndAction: { percentage in
                    vm.seek(progress: percentage, end: true)
                })
            MainToolbar<ViewModel>()
            SubToolbar()
        }
        .padding(.horizontal, space(4))
        .padding(.vertical, space(2))
        .padding(.top, space(6))
        .foregroundColor(Color("grey400"))
    }
}

struct PlayerBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerBar<FakePlayerViewModel>()
            .preferredColorScheme(.dark)
            .environmentObject(FakePlayerViewModel(song: nil, track: nil, isPlaying: true, currentProgress: 0.8))
            .frame(maxWidth: space(100))
            .background(Color("grey600"))

        PlayerBar<FakePlayerViewModel>()
            .preferredColorScheme(.dark)
            .environmentObject(
                FakePlayerViewModel(
                    song: createSong(name: "This is a really long song title that breaks into multiple lines"),
                    track: nil,
                    isPlaying: true,
                    currentProgress: 0.8
                )
            )
            .frame(maxWidth: space(100))
            .background(Color("grey600"))
    }
}

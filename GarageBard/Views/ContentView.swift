//
//  ContentView.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/4/22.
//

import Combine
import SwiftUI

func space(_ value: Int) -> CGFloat {
    CGFloat(value * 4)
}

struct FloatWindowButton<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @State var isHovering: Bool = false

    var body: some View {
        Button(action: { vm.floatWindow.toggle() }) {
            if vm.floatWindow {
                if isHovering {
                    Image(systemName: "pip.remove")
                        .font(.system(size: 14))
                        .foregroundColor(Color("grey400"))
                        .contentShape(Rectangle())
                } else {
                    Image(systemName: "pip.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("grey400"))
                        .contentShape(Rectangle())
                }
            } else {
                if isHovering {
                    Image(systemName: "pip.enter")
                        .font(.system(size: 14))
                        .foregroundColor(Color("grey400"))
                        .contentShape(Rectangle())
                } else {
                    Image(systemName: "pip")
                        .font(.system(size: 14))
                        .foregroundColor(Color("grey400"))
                        .contentShape(Rectangle())
                }
            }
        }
        .buttonStyle(.plain)
        .padding(space(2))
        .help(vm.floatWindow ? "Disable overlay" : "Enable overlay")
        .onHover { isHovering = $0 }
    }
}

struct ContentView<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    var body: some View {
        ZStack {
            Color("grey600")
            VStack {
                PlayerBar<ViewModel>()
                SongLibrary<ViewModel>()
            }
            .overlay {
                Notifications<ViewModel>()
            }
            VStack {
                HStack {
                    Spacer()
                    FloatWindowButton<ViewModel>()
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: space(100), height: space(150))
        .onAppear {
            // Don't auto-focus on anything on appear
            DispatchQueue.main.async {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
        .onTapGesture {
            // Clicking away from textfields should make them lose focus
            DispatchQueue.main.async {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let song = createSong(name: "My Song")

    static var previews: some View {
        Group {
            ContentView<FakePlayerViewModel>()
                .preferredColorScheme(.dark)
                .environmentObject(
                    FakePlayerViewModel(
                        song: song, track: song.tracks[0]
                    )
                )
        }
    }
}

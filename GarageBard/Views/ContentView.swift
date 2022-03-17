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
                    Button(action: { vm.floatWindow.toggle() }) {
                        if vm.floatWindow {
                            Image(systemName: "pip.remove")
                                .font(.system(size: 14))
                                .foregroundColor(Color("grey400"))
                        } else {
                            Image(systemName: "pip.enter")
                                .font(.system(size: 14))
                                .foregroundColor(Color("grey400"))
                        }
                    }
                    .padding(space(2))
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: space(100), height: space(150))
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

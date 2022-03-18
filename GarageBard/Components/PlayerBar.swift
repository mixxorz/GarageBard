//
//  PlayerBar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct PlayerBar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @State var isSubtoolbarOpen = false

    let formatter = TimeFormatter.instance

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(vm.currentProgress > 0 ? formatter.format(vm.currentPosition) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(10), alignment: .leading)
                Spacer()
                Text(vm.song?.name ?? "No song selected")
                    .font(.system(size: 14.0))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                Text(vm.currentProgress > 0 ? formatter.format(vm.timeLeft) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(10), alignment: .trailing)
            }
            ProgressBar(value: vm.currentProgress)
                .frame(height: space(1))
                .onSeek(seekAction: { percentage in
                    vm.seek(progress: percentage, end: false)
                }, seekEndAction: { percentage in
                    vm.seek(progress: percentage, end: true)
                })
            MainToolbar<ViewModel>(isSubToolbarOpen: $isSubtoolbarOpen)
            if isSubtoolbarOpen {
                SubToolbar<ViewModel>()
            }
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
                    song: createSong(name: "This is a really long song title that breaks into multiple lines", durationInSeconds: 5700),
                    track: nil,
                    isPlaying: true,
                    currentProgress: 0.42
                )
            )
            .frame(maxWidth: space(100))
            .background(Color("grey600"))
    }
}

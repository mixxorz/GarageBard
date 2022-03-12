//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct PlaylistItemRow<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    
    var song: Song
    
    let formatter = TimeFormatter.instance
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Button(action: {
                    vm.song = song
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 10.0))
                        .foregroundColor(Color("grey400"))
                        .frame(width: space(8), height: space(8))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Text(song.name)
                    .foregroundColor(Color.white)
                Spacer()
                Text(formatter.format(song.durationInSeconds))
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
            }
            Divider()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            vm.song = song
        })
    }
}

struct PlaylistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemRow<FakePlayerViewModel>(song: createSong())
            .frame(maxWidth: space(100))
            .padding(.horizontal, space(4))
            .preferredColorScheme(.dark)
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}

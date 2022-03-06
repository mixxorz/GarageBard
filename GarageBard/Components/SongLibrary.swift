//
//  SongLibrary.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct SongLibrary<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            Color("grey700")
            ScrollView {
                VStack {
                    PlaylistItemRow(
                        name: "Still Alive",
                        action: {
                            model.loadSongFromName(songName: "still-alive")
                    })
                    PlaylistItemRow(
                        name: "For Sure - Sax",
                        action: {
                            model.loadSongFromName(songName: "for-sure-sax")
                    })
                    PlaylistItemRow(
                        name: "For Sure - All",
                        action: {
                            model.loadSongFromName(songName: "for-sure-all")
                    })
                }
                .padding(space(4))
            }
        }
    }
}

struct SongLibrary_Previews: PreviewProvider {
    static var previews: some View {
        SongLibrary<FakePlayerViewModel>()
            .frame(maxWidth: space(100))
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}

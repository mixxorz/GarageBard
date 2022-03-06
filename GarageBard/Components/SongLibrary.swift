//
//  SongLibrary.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct SongLibrary<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    @State private var songs: [Song] = []
    
    var body: some View {
        ZStack {
            Color("grey700")
            ScrollView {
                VStack {
                    ForEach(songs) { song in
                        PlaylistItemRow<Model>(song: song)
                    }
                }
                .padding(space(4))
            }
        }
        .onAppear {
            let stillAlive: Song = model.loadSongFromName(songName: "still-alive")
            let forSureSax = model.loadSongFromName(songName: "for-sure-sax")
            let forSureAll = model.loadSongFromName(songName: "for-sure-all")
            
            songs = [stillAlive, forSureSax, forSureAll]
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

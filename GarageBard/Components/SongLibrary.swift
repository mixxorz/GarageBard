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
                    Text("Choose song")
                        .onTapGesture {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            panel.allowedContentTypes = [.midi]
                            
                            if panel.runModal() == .OK {
                                if let url = panel.url {
                                    let song = model.loadSongFromURL(url: url)
                                    songs = [song]
                                }
                            }
                        }
                }
                .padding(space(4))
            }
        }
//        .onAppear {
//            let stillAlive = model.loadSongFromName(songName: "still-alive")
//            let forSureSax = model.loadSongFromName(songName: "for-sure-sax")
//            let forSureAll = model.loadSongFromName(songName: "for-sure-all")
//            let songOfAncients = model.loadSongFromURL(url: URL(fileURLWithPath: "/Users/mixxorz/Downloads/AuraDj_-_NierRe_-_Song_of_the_Ancients_Devola.mid"))
            
            
//            songs = [stillAlive, forSureSax, forSureAll, songOfAncients]
//        }
    }
}

struct SongLibrary_Previews: PreviewProvider {
    static var previews: some View {
        SongLibrary<FakePlayerViewModel>()
            .frame(maxWidth: space(100))
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}

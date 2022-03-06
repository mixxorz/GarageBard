//
//  FakePlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import Foundation


class FakePlayerViewModel: PlayerViewModelProtocol {
    var song: Song?
    var track: Track?
    var isPlaying: Bool = false
    
    
    init(song: Song?, track: Track?) {
        self.song = song
        self.track = track
    }
    
    func playOrPause() {
    }
    
    func stop() {
    }
    
    func setSong(song: Song) {
    }
    
    func setTrack(track: Track) {
    }
    
    func loadSongFromName(songName: String) -> Song {
        return Song(name: songName, tracks: [
            Track(id: 0, name: "Saxophone"),
            Track(id: 1, name: "Guitar"),
        ])
    }
}

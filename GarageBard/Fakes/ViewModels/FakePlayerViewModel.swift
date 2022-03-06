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
    
    func playOrPause() {
    }
    
    func stop() {
    }
    
    func setSong(song: Song) {
    }
    
    func setTrack(track: Track) {
    }
    
    func loadSongFromName(songName: String) {
    }
}

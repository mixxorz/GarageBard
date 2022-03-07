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
    var currentPosition: Double = 0
    var currentProgress: Double = 0
    var timeLeft: Double = 0
    
    
    init(song: Song?, track: Track?, isPlaying: Bool = false, currentProgress: Double = 0.3) {
        self.song = song
        self.track = track
        self.isPlaying = isPlaying
        
        let duration = 123.0
        self.currentPosition = duration * currentProgress
        self.currentProgress = currentProgress
        self.timeLeft = currentPosition - duration
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
        return Song(
            name: songName,
            durationInSeconds: 200.0,
            tracks: [
                Track(id: 0, name: "Saxophone"),
                Track(id: 1, name: "Guitar"),
            ]
        )
    }
}

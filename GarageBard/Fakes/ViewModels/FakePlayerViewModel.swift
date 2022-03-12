//
//  FakePlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import Foundation


func createSong(name: String = "GarageBard", durationInSeconds: Double = 150.0) -> Song {
     return Song(
        name: name,
        url: URL(fileURLWithPath: "some.mid"),
        durationInSeconds: durationInSeconds,
        tracks: [
            Track(id: 0, name: "Saxophone"),
            Track(id: 1, name: "Guitar"),
            Track(id: 2, name: "Lute"),
            Track(id: 3, name: "Drum Kit"),
            Track(id: 4, name: "Electric Guitar"),
            Track(id: 5, name: "Violin")
        ]
    )
}

class FakePlayerViewModel: PlayerViewModelProtocol {
    var song: Song?
    var track: Track?
    var isPlaying: Bool = false
    var currentPosition: Double = 0
    var currentProgress: Double = 0
    var timeLeft: Double = 0
    var songs: [Song] = []
    var playMode: PlayMode = .perform
    var hasAccessibilityPermissions: Bool = true
    
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
    
    func openLoadSongDialog() {
    }
    
    func makeSong(name: String) {
        songs.append(
            Song(
                name: name,
                url: URL(fileURLWithPath: "some.mid"),
                durationInSeconds: 123.0,
                tracks: []
            )
        )
    }
    
    func loadSong(fromURL url: URL) {
    }
    
    func seek(progress: Double, end: Bool) {
    }
    
    func checkAccessibilityPermissions(prompt: Bool) {
    }
}

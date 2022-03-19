//
//  FakePlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import Foundation

func createSong(name: String = "GarageBard", durationInSeconds: Double = 150.0) -> Song {
    Song(
        name: name,
        url: URL(fileURLWithPath: "some.mid"),
        durationInSeconds: durationInSeconds,
        tracks: [
            Track(id: 0, name: "Saxophone"),
            Track(id: 1, name: "Guitar"),
            Track(id: 2, name: "Lute"),
            Track(id: 3, name: "Drum Kit"),
            Track(id: 4, name: "Electric Guitar"),
            Track(id: 5, name: "Violin"),
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
    var notesTransposed: Bool = false
    var hasAccessibilityPermissions: Bool = true
    var foundXIVprocess: Bool = true
    var floatWindow: Bool = false

    init(
        song: Song? = nil,
        track: Track? = nil,
        isPlaying: Bool = false,
        currentProgress: Double = 0.3,
        songs: [Song] = [],
        hasAccessibilityPermissions: Bool = true,
        foundXIVprocess: Bool = true
    ) {
        self.song = song
        self.track = track
        self.isPlaying = isPlaying
        self.songs = songs

        if let song = song {
            let duration = song.durationInSeconds
            currentPosition = duration * currentProgress
            self.currentProgress = currentProgress
            timeLeft = currentPosition - duration
        }

        self.hasAccessibilityPermissions = hasAccessibilityPermissions
        self.foundXIVprocess = foundXIVprocess
    }

    func playOrPause() {}

    func stop() {}

    func openLoadSongDialog() {}

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

    func loadSong(fromURL _: URL) {}

    func seek(progress _: Double, end _: Bool) {}

    func setTransposeAmount(fromString _: String) {}
    func setArpeggiateChords(value _: Bool) {}

    func checkAccessibilityPermissions(prompt _: Bool) {}

    func findXIVProcess() {}
}

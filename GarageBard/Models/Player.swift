//
//  Player.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI
import Foundation
import Combine

struct Track: Hashable, Identifiable {
    var id: Int
    var name: String
}

struct Song: Identifiable {
    var id: String { self.name }
    var name: String
    var tracks: [Track]
}

class Player {
    var song: AnyPublisher<Song?, Never> {
        songValue.eraseToAnyPublisher()
    }
    var track: AnyPublisher<Track?, Never> {
        trackValue.eraseToAnyPublisher()
    }
    var isPlaying: AnyPublisher<Bool, Never> {
        isPlayingValue.eraseToAnyPublisher()
    }
    
    // State variables
    private let songValue = CurrentValueSubject<Song?, Never>(nil)
    private let trackValue = CurrentValueSubject<Track?, Never>(nil)
    private let isPlayingValue = CurrentValueSubject<Bool, Never>(false)
    
    private let bardEngine = BardEngine()
    private var timer: Timer?
    
    func setSong(song: Song) {
        songValue.value = song
        
        // Set default track when setting a song
        if trackValue.value == nil || !song.tracks.contains(trackValue.value!) {
            trackValue.value = song.tracks[0]
        }
        
        isPlayingValue.value = false
        bardEngine.loadSong(song: song, track: song.tracks[0])
    }
    
    func setTrack(track: Track) {
        trackValue.value = track
        isPlayingValue.value = false
        bardEngine.loadSong(song: songValue.value!, track: track)
    }
    
    func loadSongFromName(songName: String) {
        let song = bardEngine.loadSong(fromName: songName)
        setSong(song: song)
    }
    
    func play() {
        self.isPlayingValue.value = true
        // Give some time for the user to switch to the game
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
            self.bardEngine.play()
        }
    }
    
    func pause() {
        timer?.invalidate()
        bardEngine.pause()
        isPlayingValue.value = false
    }
    
    func stop() {
        timer?.invalidate()
        bardEngine.stop()
        isPlayingValue.value = false
    }
}

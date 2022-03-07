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
    var durationInSeconds: Double
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
    var currentPosition: AnyPublisher<Double, Never> {
        currentPositionValue.eraseToAnyPublisher()
    }
    
    // State variables
    private let songValue = CurrentValueSubject<Song?, Never>(nil)
    private let trackValue = CurrentValueSubject<Track?, Never>(nil)
    private let isPlayingValue = CurrentValueSubject<Bool, Never>(false)
    private let currentPositionValue = CurrentValueSubject<Double, Never>(0)
    
    private let bardEngine = BardEngine()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    init() {
        bardEngine.$isPlaying.assign(to: \.isPlayingValue.value, on: self).store(in: &cancellables)
        bardEngine.$currentPosition.assign(to: \.currentPositionValue.value, on: self).store(in: &cancellables)
    }
    
    func setSong(song: Song) {
        stop()
        
        songValue.value = song
        
        // Set default track when setting a song
        if trackValue.value == nil || !song.tracks.contains(trackValue.value!) {
            trackValue.value = song.tracks[0]
        }
        
        bardEngine.loadSong(song: song, track: song.tracks[0])
    }
    
    func setTrack(track: Track) {
        stop()
        
        trackValue.value = track
        bardEngine.loadSong(song: songValue.value!, track: track)
    }
    
    func loadSongFromName(songName: String) -> Song {
        return bardEngine.loadSong(fromName: songName)
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
    }
    
    func stop() {
        timer?.invalidate()
        bardEngine.stop()
    }
}

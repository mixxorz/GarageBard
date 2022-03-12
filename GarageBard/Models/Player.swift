//
//  Player.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI
import Foundation
import Combine

enum PlayMode {
    case listen, perform
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
    var playMode: AnyPublisher<PlayMode, Never> {
        playModeValue.eraseToAnyPublisher()
    }
    
    // State variables
    private let songValue = CurrentValueSubject<Song?, Never>(nil)
    private let trackValue = CurrentValueSubject<Track?, Never>(nil)
    private let isPlayingValue = CurrentValueSubject<Bool, Never>(false)
    private let currentPositionValue = CurrentValueSubject<Double, Never>(0)
    private let playModeValue = CurrentValueSubject<PlayMode, Never>(.perform)
    
    private let bardEngine = BardEngine()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bardEngine.$isPlaying.assign(to: \.isPlayingValue.value, on: self).store(in: &cancellables)
        bardEngine.$currentPosition.assign(to: \.currentPositionValue.value, on: self).store(in: &cancellables)
        
        playModeValue.assign(to: \.playMode, on: bardEngine).store(in: &cancellables)
    }
    
    func setSong(song: Song) {
        stop()
        
        songValue.value = song
        
        // Set default track when setting a song
        if trackValue.value == nil || !song.tracks.contains(trackValue.value!) {
            trackValue.value = song.tracks[0]
        }
        
        bardEngine.loadSong(song: song)
    }
    
    func setTrack(track: Track) {
        trackValue.value = track
        bardEngine.loadTrack(track: track)
    }
    
    func setPlayMode(playMode: PlayMode) {
        playModeValue.value = playMode
    }
    
    func play() {
        self.bardEngine.play()
    }
    
    func pause() {
        bardEngine.pause()
    }
    
    func stop() {
        bardEngine.stop()
    }
    
    func seek(_ progress: Double) {
        if let song = songValue.value {
            bardEngine.setTime(song.durationInSeconds * progress)
        }
    }
}

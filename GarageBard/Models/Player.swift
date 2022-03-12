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

struct Track: Hashable, Identifiable {
    var id: Int
    var name: String
}

struct Song: Identifiable, Equatable {
    var id: String { self.name }
    var name: String
    var url: URL?
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
    var songs: AnyPublisher<[Song], Never> {
        songsValue.eraseToAnyPublisher()
    }
    var playMode: AnyPublisher<PlayMode, Never> {
        playModeValue.eraseToAnyPublisher()
    }
    
    // State variables
    private let songValue = CurrentValueSubject<Song?, Never>(nil)
    private let trackValue = CurrentValueSubject<Track?, Never>(nil)
    private let isPlayingValue = CurrentValueSubject<Bool, Never>(false)
    private let currentPositionValue = CurrentValueSubject<Double, Never>(0)
    private let songsValue = CurrentValueSubject<[Song], Never>([])
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
        
        bardEngine.loadSong(song: song, track: song.tracks[0])
    }
    
    func setTrack(track: Track) {
        stop()
        
        trackValue.value = track
        bardEngine.loadSong(song: songValue.value!, track: track)
    }
    
    func setPlayMode(playMode: PlayMode) {
        playModeValue.value = playMode
    }
    
    func loadSongFromURL(url: URL) {
        let song = bardEngine.loadSong(fromURL: url)
        songsValue.value.append(song)
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
}

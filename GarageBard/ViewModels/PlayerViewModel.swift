//
//  PlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import Combine


class PlayerViewModel: PlayerViewModelProtocol {
    @Published var song: Song? = nil
    @Published var track: Track? = nil
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var timeLeft: Double = 0
    
    private var model: Player
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: Player = Player()) {
        self.model = model
        
        model.song.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.song }.assign(to: &$song)
        model.track.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.track }.assign(to: &$track)
        model.isPlaying.receive(on: DispatchQueue.main).assign(to: &$isPlaying)
        model.currentPosition.sink(receiveValue: { [weak self] position in
            guard let self = self else { return }
            self.currentPosition = position
            
            if let song = self.song {
                self.currentProgress = position / song.durationInSeconds
                self.timeLeft = position - song.durationInSeconds
            } else {
                self.currentProgress = 0
                self.timeLeft = 0
            }
        }).store(in: &cancellables)
        
        $song.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if let newSong = $0 {
                self.model.setSong(song: newSong)
            }
        }).store(in: &cancellables)
        
        $track.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if let newTrack = $0 {
                self.model.setTrack(track: newTrack)
            }
        }).store(in: &cancellables)
    }
    
    func playOrPause() {
        if isPlaying {
            model.pause()
        } else {
            model.play()
        }
    }
    
    func stop() {
        model.stop()
    }
    
    func loadSongFromName(songName: String) -> Song {
        return model.loadSongFromName(songName: songName)
    }
    
    func loadSongFromURL(url: URL) -> Song {
        return model.loadSongFromPath(url: url)
    }
}

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
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0
    @Published var currentProgress: Double = 0
    @Published var timeLeft: Double = 0
    
    private var model: Player
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: Player = Player()) {
        self.model = model
        
        model.song.receive(on: DispatchQueue.main).assign(to: \.song, on: self).store(in: &cancellables)
        model.track.receive(on: DispatchQueue.main).assign(to: \.track, on: self).store(in: &cancellables)
        model.isPlaying.receive(on: DispatchQueue.main).assign(to: \.isPlaying, on: self).store(in: &cancellables)
        model.currentPosition.sink(receiveValue: { [weak self] position in
            guard let self = self else { return }
            self.currentPosition = position
            
            if let song = self.song {
                self.currentProgress = position / song.durationInSeconds
                self.timeLeft = position - song.durationInSeconds
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .positional
                formatter.zeroFormattingBehavior = .pad
            } else {
                self.currentProgress = 0
                self.timeLeft = 0
            }
        }).store(in: &cancellables)
        
        $track.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if $0 != nil && $0 != self.track {
                self.model.setTrack(track: $0!)
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
    
    func setSong(song: Song) {
        model.setSong(song: song)
    }
    
    func setTrack(track: Track) {
        model.setTrack(track: track)
    }
    
    func loadSongFromName(songName: String) -> Song {
        return model.loadSongFromName(songName: songName)
    }
}

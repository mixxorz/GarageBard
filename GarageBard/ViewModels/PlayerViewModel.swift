//
//  PlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import Combine


class PlayerViewModel: ObservableObject {
    @Published var song: Song? = nil
    @Published var track: Track? = nil
    @Published var isPlaying: Bool = false
    
    private var model: Player
    
    private var songSubscription: Cancellable!
    private var trackSubscription: Cancellable!
    private var isPlayingSubscription: Cancellable!
    
    private var setTrackSubscription: Cancellable!
    
    init(model: Player = Player()) {
        self.model = model
        
        songSubscription = model.song.receive(on: DispatchQueue.main).assign(to: \.song, on: self)
        trackSubscription = model.track.receive(on: DispatchQueue.main).assign(to: \.track, on: self)
        isPlayingSubscription = model.isPlaying.receive(on: DispatchQueue.main).assign(to: \.isPlaying, on: self)
        
        setTrackSubscription = $track.sink(receiveValue: {
            if $0 != nil && $0 != self.track {
                self.model.setTrack(track: $0!)
            }
        })
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
    
    func loadSongFromName(songName: String) {
        model.loadSongFromName(songName: songName)
    }
}

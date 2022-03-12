//
//  PlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import Combine
import SwiftUI


class PlayerViewModel: PlayerViewModelProtocol {
    @Published var song: Song? = nil
    @Published var track: Track? = nil
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var timeLeft: Double = 0
    @Published private(set) var songs: [Song] = []
    @Published var playMode: PlayMode = .perform
    @Published var hasAccessibilityPermissions: Bool = false
    
    private var model: Player
    
    private var seekTimer: Timer?
    private var isSeeking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: Player = Player()) {
        self.model = model
        
        model.song.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.song }.assign(to: &$song)
        model.track.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.track }.assign(to: &$track)
        model.isPlaying.receive(on: DispatchQueue.main).assign(to: &$isPlaying)
        model.songs.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.songs }.assign(to: &$songs)
        model.currentPosition.sink(receiveValue: { [weak self] position in
            guard let self = self else { return }
            self.currentPosition = position
            
            if let song = self.song {
                if !self.isSeeking {
                    self.currentProgress = position / song.durationInSeconds
                }
                self.timeLeft = position - song.durationInSeconds
            } else {
                if !self.isSeeking {
                    self.currentProgress = 0
                }
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
        
        $playMode.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            self.model.setPlayMode(playMode: $0)
        }).store(in: &cancellables)
        
        checkAccessibilityPermissions(prompt: false)
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
    
    func openLoadSongDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.midi]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                model.loadSongFromURL(url: url)
            }
        }
    }
    
    func loadSong(fromURL url: URL) {
        model.loadSongFromURL(url: url)
    }
    
    func seek(progress: Double, end: Bool) {
        if song != nil {
            isSeeking = true
            currentProgress = progress
            // Make sure to debounce the seek calls
            seekTimer?.invalidate()
            seekTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
                self?.model.seek(progress)
                
                if end {
                    self?.isSeeking = false
                }
            }
        }
        
    }
    
    func checkAccessibilityPermissions(prompt: Bool) {
        withAnimation {
            if prompt {
                let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
                self.hasAccessibilityPermissions = AXIsProcessTrustedWithOptions(options)
            } else {
                self.hasAccessibilityPermissions = AXIsProcessTrusted()
            }
        }
    }
}

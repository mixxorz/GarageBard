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
    @Published var foundXIVprocess: Bool = false
    
    private var player: Player
    private var songLoader: SongLoader
    
    private var seekTimer: Timer?
    private var isSeeking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(player: Player = Player(), songLoader: SongLoader = SongLoader()) {
        self.player = player
        self.songLoader = songLoader
        
        player.song.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.song }.assign(to: &$song)
        player.track.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.track }.assign(to: &$track)
        player.isPlaying.receive(on: DispatchQueue.main).assign(to: &$isPlaying)
        songLoader.songs.receive(on: DispatchQueue.main).filter { [weak self] in $0 != self?.songs }.assign(to: &$songs)
        player.currentPosition.sink(receiveValue: { [weak self] position in
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
                self.player.setSong(song: newSong)
            }
        }).store(in: &cancellables)
        
        $track.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if let newTrack = $0 {
                self.player.setTrack(track: newTrack)
            }
        }).store(in: &cancellables)
        
        $playMode.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            self.player.setPlayMode(playMode: $0)
        }).store(in: &cancellables)
        
        checkAccessibilityPermissions(prompt: false)
        findXIVProcess()
    }
    
    func playOrPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func stop() {
        player.stop()
    }
    
    func openLoadSongDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.midi]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                songLoader.addSong(fromURL: url)
            }
        }
    }
    
    func loadSong(fromURL url: URL) {
        songLoader.addSong(fromURL: url)
    }
    
    func seek(progress: Double, end: Bool) {
        if song != nil {
            isSeeking = true
            currentProgress = progress
            // Make sure to debounce the seek calls
            seekTimer?.invalidate()
            seekTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
                self?.player.seek(progress)
                
                if end {
                    self?.isSeeking = false
                }
            }
        }
        
    }
    
    func checkAccessibilityPermissions(prompt: Bool) {
        withAnimation(.spring()) {
            if prompt {
                let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
                self.hasAccessibilityPermissions = AXIsProcessTrustedWithOptions(options)
            } else {
                self.hasAccessibilityPermissions = AXIsProcessTrusted()
            }
        }
    }
    
    func findXIVProcess() {
        ProcessManager.instance.setXIVProcessId()
        
        withAnimation(.spring()) {
            if ProcessManager.instance.getXIVProcessId() != nil {
                self.foundXIVprocess = true
            } else {
                self.foundXIVprocess = false
            }
        }
    }
}

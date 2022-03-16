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
    
    // Settings
    @Published var playMode: PlayMode = .perform
    @Published var autoCmdTab: Bool = false
    
    @Published var hasAccessibilityPermissions: Bool = false
    @Published var foundXIVprocess: Bool = false
    
    private var bardEngine: BardEngine
    private var songLoader: SongLoader
    
    private var seekTimer: Timer?
    private var isSeeking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        bardEngine: BardEngine = BardEngine(playMode: .perform, autoCmdTab: false),
        songLoader: SongLoader = SongLoader()
    ) {
        self.bardEngine = bardEngine
        self.songLoader = songLoader
        
        // Update isPlaying when bardEngine finishes playing
        self.bardEngine.$isPlaying.assign(to: &$isPlaying)
        
        // Update playing progress values
        self.bardEngine.$currentPosition.sink(receiveValue: { [weak self] position in
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
        
        // When the song changes, load it into bardEngine
        $song.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if let newSong = $0 {
                self.stop()
                withAnimation(.spring()) {
                    self.track = newSong.tracks.first
                }
                self.bardEngine.loadSong(song: newSong)
            }
        }).store(in: &cancellables)
        
        // When the track changes, load it into bardEngine
        $track.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            
            if let newTrack = $0 {
                self.bardEngine.loadTrack(track: newTrack)
            }
        }).store(in: &cancellables)
        
        // When the playMode changes, update that in bardEngine
        $playMode.assign(to: \.playMode, on: self.bardEngine).store(in: &cancellables)
        
        // When autoCmdTab changes, update that in bardEngine
        $autoCmdTab.assign(to: \.autoCmdTab, on: self.bardEngine).store(in: &cancellables)
        
        // Boot up chores
        checkAccessibilityPermissions(prompt: false)
        findXIVProcess()
    }
    
    /// Open file picker to load a song
    func openLoadSongDialog() {
        if let loadedSong = songLoader.openLoadSongDialog() {
            songs.append(loadedSong)
        }
    }
    
    /// Load a song given URL
    func loadSong(fromURL url: URL) {
        let song = songLoader.openSong(fromURL: url)
        songs.append(song)
    }
    
    /// Play or pause playback
    func playOrPause() {
        if isPlaying {
            bardEngine.pause()
        } else {
            bardEngine.play()
        }
    }
    
    /// Stop playback
    func stop() {
        bardEngine.stop()
    }
    
    /// Seek playback
    /// - parameter progress: Time in seconds to seek
    /// - parameter end: If done seeking
    func seek(progress: Double, end: Bool) {
        if let currentSong = song {
            isSeeking = true
            currentProgress = progress
            currentPosition = progress * currentSong.durationInSeconds
            timeLeft = currentPosition - currentSong.durationInSeconds
            // Make sure to debounce the seek calls
            seekTimer?.invalidate()
            seekTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
                self?.bardEngine.setTime(currentSong.durationInSeconds * progress)
                
                if end {
                    self?.isSeeking = false
                }
            }
        }
    }
    
    /// Check if the app currently has accessibility access
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
    
    /// Find and save the game process
    func findXIVProcess() {
        ProcessManager.instance.findXIV()
        
        withAnimation(.spring()) {
            if ProcessManager.instance.getXIVProcessId() != nil {
                self.foundXIVprocess = true
            } else {
                self.foundXIVprocess = false
            }
        }
    }
}

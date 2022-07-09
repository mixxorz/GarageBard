//
//  PlayerViewModel.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Combine
import Foundation
import SwiftUI

class PlayerViewModel: PlayerViewModelProtocol {
    @Published var song: Song? = nil
    @Published var track: Track? = nil
    @Published var songs: [Song] = []
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var timeLeft: Double = 0

    // Settings
    @Published var playMode: PlayMode = .perform
    @Published var loopMode: LoopMode = .off
    @Published var continuousPlayback: Bool = false

    /// If the currently loaded track has been transposed
    @Published var notesTransposed: Bool = false
    @Published var hasAccessibilityPermissions: Bool = false
    @Published var foundXIVprocess: Bool = false

    @Published var floatWindow: Bool = false

    private var bardEngine: BardEngine
    private var songLoader: SongLoader
    private var midiController: MIDIController

    private var seekTimer: Timer?
    private var isSeeking: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(
        bardEngine: BardEngine = BardEngine(playMode: .perform),
        songLoader: SongLoader = SongLoader(),
        midiController: MIDIController = MIDIController()
    ) {
        self.bardEngine = bardEngine
        self.songLoader = songLoader
        self.midiController = midiController

        // Update state from bardEngine
        self.bardEngine.$isPlaying.assign(to: &$isPlaying)

        // Play next song after the current one finishes
        self.bardEngine.onStop { [weak self] finished in
            guard let self = self else { return }
            guard let song = self.song else { return }

            if self.continuousPlayback, finished, let songIndex = self.songs.firstIndex(of: song) {
                if songIndex + 1 < self.songs.count {
                    self.song = self.songs[songIndex + 1]
                    self.bardEngine.play()
                } else if self.loopMode == .session, let nextSong = self.songs.first {
                    // If there is no next song, and loop mode is "session", play the first song again
                    self.song = nextSong
                    self.bardEngine.play()
                }
            }
        }

        self.bardEngine.$currentPosition.sink(receiveValue: { [weak self] position in
            guard let self = self else { return }

            if let song = self.song {
                // Have to modulo here because `position` will be greater than the length of the song when if it's looping.
                self.currentPosition = position.truncatingRemainder(dividingBy: song.durationInSeconds)

                if !self.isSeeking {
                    self.currentProgress = self.currentPosition / song.durationInSeconds
                }
                self.timeLeft = self.currentPosition - song.durationInSeconds
            } else {
                if !self.isSeeking {
                    self.currentProgress = 0
                }
                self.timeLeft = 0
            }
        }).store(in: &cancellables)

        self.bardEngine.$notesTransposed.assign(to: &$notesTransposed)

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

        // When the loopMode changes, update that in bardEngine
        $loopMode.assign(to: \.loopMode, on: self.bardEngine).store(in: &cancellables)

        // Float window on change
        $floatWindow.sink(receiveValue: {
            if let mainWindow = NSApplication.shared.mainWindow {
                if $0 {
                    mainWindow.level = .init(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.overlayWindow)))
                } else {
                    mainWindow.level = .normal
                }
            }

        }).store(in: &cancellables)

        // Boot up chores
        checkAccessibilityPermissions(prompt: false)
        findXIVProcess()
    }

    /// Open file picker to load a song
    func openLoadSongDialog() {
        if let loadedSong = songLoader.openLoadSongDialog() {
            withAnimation(.spring()) {
                songs.append(loadedSong)
            }
        }
    }

    /// Load a song given URL
    func loadSong(fromURL url: URL) {
        let song = songLoader.openSong(fromURL: url)
        withAnimation(.spring()) {
            songs.append(song)
        }
    }

    /// Remove's song from library
    func removeSong(song: Song) {
        withAnimation(.spring()) {
            songs.removeAll { $0 == song }

            if self.song == song {
                stop()
                self.song = nil
                self.track = nil
            }
        }
    }

    /// Reloads the current track
    ///
    /// This will reapply track effects
    func reloadTrack() {
        guard let track = track else { return }
        bardEngine.loadTrack(track: track)
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
        bardEngine.stop(finished: false)
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

    /// Updates the transpose amount of the current track and reloads it
    func setTransposeAmount(fromString value: String) {
        guard let track = track else { return }
        track.setTransposeAmount(fromString: value)
        reloadTrack()
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

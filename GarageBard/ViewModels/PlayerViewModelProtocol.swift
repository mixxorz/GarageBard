//
//  PlayerViewModelProtocol.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import Foundation

protocol PlayerViewModelProtocol: ObservableObject {
    var song: Song? { get set }
    var track: Track? { get set }
    var isPlaying: Bool { get }
    var currentPosition: Double { get }
    var currentProgress: Double { get }
    var timeLeft: Double { get }
    var songs: [Song] { get set }
    var playMode: PlayMode { get set }
    var loopMode: LoopMode { get set }
    var continuousPlayback: Bool { get set }
    var notesTransposed: Bool { get }
    var hasAccessibilityPermissions: Bool { get }
    var foundXIVprocess: Bool { get }
    var floatWindow: Bool { get set }
    var midiDeviceNames: [String] { get }

    func playOrPause()
    func stop()
    func openLoadSongDialog()
    func loadSong(fromURL url: URL)
    func removeSong(song: Song)
    func reloadTrack()
    func seek(progress: Double, end: Bool)

    func setTransposeAmount(fromString value: String)

    func checkAccessibilityPermissions(prompt: Bool)
    func findXIVProcess()
}

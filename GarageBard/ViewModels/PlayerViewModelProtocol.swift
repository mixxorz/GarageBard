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
    var songs: [Song] { get }
    var playMode: PlayMode { get set }
    var autoCmdTab: Bool { get set }
    var hasAccessibilityPermissions: Bool { get }
    var foundXIVprocess: Bool { get }
    
    func playOrPause()
    func stop()
    func openLoadSongDialog()
    func loadSong(fromURL url: URL)
    func seek(progress: Double, end: Bool)
    func checkAccessibilityPermissions(prompt: Bool)
    func findXIVProcess()
}

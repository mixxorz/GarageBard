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
    var isPlaying: Bool { get set }
    var currentPosition: Double { get set }
    var currentProgress: Double { get set }
    var timeLeft: Double { get set }
    
    func playOrPause()
    func stop()
    func setSong(song: Song)
    func setTrack(track: Track)
    func loadSongFromName(songName: String) -> Song
}

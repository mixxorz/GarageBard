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
    
    func playOrPause()
    func stop()
    func setSong(song: Song)
    func loadSongFromName(songName: String) -> Song
}

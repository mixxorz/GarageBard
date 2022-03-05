//
//  Player.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI
import Foundation
import Combine
import AudioKit

struct Track: Identifiable {
    var id: Int
    var name: String
}

struct Song {
    var name: String
    var tracks: [Track]
}


class BardEngine {
    private let engine = AudioEngine()
    private let sequencer = AppleSequencer()
    private let sampler = MIDISampler()
    private let instrument = MIDICallbackInstrument()
    
    init() {
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        try? engine.start()
        
        
        func midiCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
            let mstat = MIDIStatusType.from(byte: status)
            if mstat == .noteOn {
                sampler.play(noteNumber: note, velocity: velocity, channel: 1)
            } else if mstat == .noteOff {
                sampler.stop(noteNumber: note, channel: 1)
            }
        }
        
        instrument.callback = midiCallback
    }
    
    func loadSong(song: Song, track: Track) {
        // Load song into sequencer
        guard let asset = NSDataAsset(name: song.name) else {
            fatalError("Missing data asset")
        }
        let data: Data = asset.data
        sequencer.stop()
        sequencer.loadMIDIFile(fromData: data)
        sequencer.rewind()
        sequencer.preroll()
        
        // TODO: Load track into sequencer
    }
    
    func play() {
        sequencer.play()
    }
    
    func pause() {
        sequencer.stop()
    }
    
    func stop() {
        sequencer.rewind()
        sequencer.stop()
    }
}


class Player {
    var song: AnyPublisher<Song?, Never> {
        songValue.eraseToAnyPublisher()
    }
    var track: AnyPublisher<Track?, Never> {
        trackValue.eraseToAnyPublisher()
    }
    var isPlaying: AnyPublisher<Bool, Never> {
        isPlayingValue.eraseToAnyPublisher()
    }
    
    // State variables
    private let songValue = CurrentValueSubject<Song?, Never>(nil)
    private let trackValue = CurrentValueSubject<Track?, Never>(nil)
    private let isPlayingValue = CurrentValueSubject<Bool, Never>(false)
    
    private let bardEngine = BardEngine()
    
    func setSong(song: Song) {
        songValue.value = song
        bardEngine.loadSong(song: song, track: song.tracks[0])
    }
    
    func setTrack(track: Track) {
        trackValue.value = track
        bardEngine.loadSong(song: songValue.value!, track: track)
    }
    
    func play() {
        bardEngine.play()
    }
    
    func pause() {
        bardEngine.pause()
    }
    
    func stop() {
        bardEngine.stop()
    }
}

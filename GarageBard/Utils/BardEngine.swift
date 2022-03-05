//
//  BardEngine.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import SwiftUI
import AudioKit
import MidiParser

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
        
        // Convoluted way to delete all tracks except the current one
        // Delete tracks up to the selected track's index
        if track.id != 0 {
            for _ in 0...track.id - 1 {
                sequencer.deleteTrack(trackIndex: 0)
            }
        }
        // 0th track is now our selected track. Delete the rest
        if sequencer.trackCount > 1 {
            for _ in 1...sequencer.trackCount - 1 {
                sequencer.deleteTrack(trackIndex: 1)
            }
        }
        
        sequencer.rewind()
        sequencer.preroll()
    }
    
    func loadSong(fromName songName: String) -> Song {
        let midi = MidiData()
        guard let asset = NSDataAsset(name: songName) else {
            fatalError("Missing data asset")
        }
        let data: Data = asset.data
        midi.load(data: data)
        
        // Load track options
        let tracks: [Track] = midi.noteTracks.enumerated().map { (index, track) in
            if (track.trackName != "") {
                return Track(id: index, name: track.trackName)
            }
            return Track(id: index, name: "Track " + String(index))
        }
        
        return Song(name: songName, tracks: tracks)
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

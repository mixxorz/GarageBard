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
import Carbon.HIToolbox

let DEMO_MODE = false

class BardEngine {
    private let sequencer: AppleSequencer = AppleSequencer()
    private let instrument = MIDICallbackInstrument()
    private let nullInstrument = MIDICallbackInstrument()
    private let bardController = BardController()
    
    init() {
        func midiCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
            let mstat = MIDIStatusType.from(byte: status)
            if mstat == .noteOn {
                bardController.noteOn(note)
            } else if mstat == .noteOff {
                bardController.noteOff(note)
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
        
        // Demo mode plays the song using the default AppleSequencer
        if !DEMO_MODE {
            // Otherwise, use hook it up with the callback instruments
            sequencer.setGlobalMIDIOutput(nullInstrument.midiIn)
            sequencer.tracks[track.id].setMIDIOutput(instrument.midiIn)
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
        bardController.start()
    }
    
    func pause() {
        sequencer.stop()
        bardController.stop()
    }
    
    func stop() {
        sequencer.rewind()
        sequencer.stop()
        bardController.stop()
    }
}

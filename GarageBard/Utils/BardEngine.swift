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
import Combine

let DEMO_MODE = false

class BardEngine {
    private let sequencer: AppleSequencer = AppleSequencer()
    private let instrument = MIDICallbackInstrument()
    private let controlInstrument = MIDICallbackInstrument()
    private let nullInstrument = MIDICallbackInstrument()
    private let bardController = BardController()
    
    @Published private(set) var isPlaying: Bool = false
    
    init() {
        instrument.callback = instrumentCallback
        controlInstrument.callback = controlCallback
    }
    
    private func instrumentCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
        let mstat = MIDIStatusType.from(byte: status)
        if mstat == .noteOn {
            print("Note ON: \(note)")
            bardController.noteOn(note)
        } else if mstat == .noteOff {
            bardController.noteOff(note)
        }
    }
    
    private func controlCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
        let mstat = MIDIStatusType.from(byte: status)
        if mstat == .noteOn {
            print("Stopping")
            stop()
        }
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
        
        let controlTrack = sequencer.newTrack()
        controlTrack?.add(
            midiNoteData: MIDINoteData(
                noteNumber: 60,
                velocity: 60,
                channel: MIDIChannel(1),
                duration: Duration(beats: 1),
                position: sequencer.length
            )
        )
        controlTrack?.setMIDIOutput(controlInstrument.midiIn)
        
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
        isPlaying = true
    }
    
    func pause() {
        sequencer.stop()
        bardController.stop()
        isPlaying = false
    }
    
    func stop() {
        sequencer.rewind()
        sequencer.stop()
        bardController.stop()
        isPlaying = false
    }
}

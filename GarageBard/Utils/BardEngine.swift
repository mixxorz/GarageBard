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

class BardEngine {
    private let sequencer: AppleSequencer = AppleSequencer()
    private let instrument = MIDICallbackInstrument()
    private let controlInstrument = MIDICallbackInstrument()
    private let nullInstrument = MIDICallbackInstrument()
    private let sampler = MIDISampler()
    private let engine = AudioEngine()
    private let bardController = BardController()
    
    private var timer: Timer?
    var playMode: PlayMode = .perform {
        didSet {
            if playMode == .perform {
                engine.stop()
            } else if playMode == .listen {
                try? engine.start()
                bardController.allNotesOff()
            }
        }
    }
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    
    init() {
        instrument.callback = instrumentCallback
        controlInstrument.callback = controlCallback
        engine.output = sampler
    }
    
    deinit {
        engine.stop()
    }
    
    private func instrumentCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
        let mstat = MIDIStatusType.from(byte: status)
        if mstat == .noteOn {
            if playMode == .perform {
                bardController.noteOn(note)
            } else if playMode == .listen {
                sampler.play(noteNumber: note, velocity: velocity, channel: 1)
            }
        } else if mstat == .noteOff {
            if playMode == .perform {
                bardController.noteOff(note)
            } else if playMode == .listen {
                sampler.stop(noteNumber: note, channel: 1)
            }
        }
    }
    
    private func controlCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
        let mstat = MIDIStatusType.from(byte: status)
        if mstat == .noteOn {
            stop()
        }
    }
    
    func loadSong(song: Song, track: Track) {
        // Load song into sequencer
        let data: Data
        if let url = song.url {
            do {
                data = try Data(contentsOf: url)
            } catch {
                NSLog("BardEngine: \(error)")
                return
            }
        } else {
            guard let asset = NSDataAsset(name: song.name) else {
                fatalError("Missing data asset")
            }
            data = asset.data
        }
        sequencer.stop()
        sequencer.loadMIDIFile(fromData: data)
        
        // Otherwise, use hook it up with the callback instruments
        sequencer.setGlobalMIDIOutput(nullInstrument.midiIn)
        if sequencer.tracks.indices.contains(track.id) {
            sequencer.tracks[track.id].setMIDIOutput(instrument.midiIn)
        } else {
            NSLog("BardEngine: Couldn't find track.")
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
        
        let tmpSequencer = AppleSequencer()
        tmpSequencer.loadMIDIFile(fromData: data)
        
        // Load track options
        let tracks: [Track] = midi.noteTracks.enumerated().map { (index, track) in
            if (track.trackName != "") {
                return Track(id: index, name: track.trackName)
            }
            return Track(id: index, name: "Track " + String(index))
        }
        
        return Song(name: songName, durationInSeconds: tmpSequencer.length.seconds, tracks: tracks)
    }
    
    func loadSong(fromURL url: URL) -> Song {
        let midi = MidiData()
        let tmpSequencer = AppleSequencer()
        
        do {
            let data = try Data(contentsOf: url)
            midi.load(data: data)
            tmpSequencer.loadMIDIFile(fromData: data)
        } catch {
            fatalError("Error opening file: \(error)")
        }
        
        // Load track options
        let tracks: [Track] = midi.noteTracks.enumerated().map { (index, track) in
            if (track.trackName != "") {
                return Track(id: index, name: track.trackName)
            }
            return Track(id: index, name: "Track " + String(index))
        }
        
        return Song(
            name: url.lastPathComponent,
            url: url,
            durationInSeconds: tmpSequencer.seconds(duration: tmpSequencer.length),
            tracks: tracks
        )
    }
    
    func play() {
        // Only play if a song is loaded
        if sequencer.length.beats > 0 {
            sequencer.play()
            bardController.start()
            isPlaying = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.currentPosition = self.sequencer.seconds(duration: self.sequencer.currentPosition)
            }
        }
    }
    
    func pause() {
        sequencer.stop()
        bardController.stop()
        timer?.invalidate()
        isPlaying = false
    }
    
    func stop() {
        sequencer.rewind()
        sequencer.stop()
        bardController.stop()
        timer?.invalidate()
        currentPosition = 0
        isPlaying = false
    }
}

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

enum PlayMode {
    case perform, listen
}

class BardEngine {
    private let sequencer: AppleSequencer = AppleSequencer()
    private let instrument = MIDICallbackInstrument()
    private let controlInstrument = MIDICallbackInstrument()
    private let nullInstrument = MIDICallbackInstrument()
    private let sampler = MIDISampler()
    private let engine = AudioEngine()
    private let bardController = BardController()
    private var controlTrack: MusicTrackManager?
    private var currentPositionTimer: Timer?
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    
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
    
    init(playMode: PlayMode) {
        self.playMode = playMode
        
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
    
    func loadSong(song: Song) {
        // Load song into sequencer
        let data: Data
        
        do {
            data = try Data(contentsOf: song.url)
        } catch {
            NSLog("BardEngine: \(error)")
            return
        }
        sequencer.stop()
        sequencer.loadMIDIFile(fromData: data)
        
        // Otherwise, use hook it up with the callback instruments
        loadTrack(track: song.tracks[0])
        
        controlTrack = sequencer.newTrack("control")
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
    
    func loadTrack(track: Track) {
        let wasPlaying = sequencer.isPlaying
        
        if wasPlaying {
            sequencer.stop()
        }
        
        sequencer.setGlobalMIDIOutput(nullInstrument.midiIn)
        if sequencer.tracks.indices.contains(track.id) {
            sequencer.tracks[track.id].setMIDIOutput(instrument.midiIn)
        } else {
            NSLog("BardEngine: Couldn't find track.")
        }
        
        controlTrack?.setMIDIOutput(controlInstrument.midiIn)
        
        if wasPlaying {
            sequencer.play()
        }
    }
    
    func play() {
        // Only play if a song is loaded
        if sequencer.length.beats > 0 {
            if playMode == .perform {
                ProcessManager.instance.switchToXIV()
            }
            
            sequencer.play()
            bardController.start()
            isPlaying = true
            
            currentPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.currentPosition = self.sequencer.seconds(duration: self.sequencer.currentPosition)
            }
        }
    }
    
    func pause() {
        sequencer.stop()
        bardController.stop()
        currentPositionTimer?.invalidate()
        isPlaying = false
    }
    
    func stop() {
        sequencer.rewind()
        sequencer.stop()
        bardController.stop()
        currentPositionTimer?.invalidate()
        currentPosition = 0
        isPlaying = false
    }
    
    func setTime(_ timestamp: Double) {
        sequencer.setTime(sequencer.duration(seconds: timestamp).beats)
    }
    
}

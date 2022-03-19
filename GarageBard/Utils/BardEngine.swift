//
//  BardEngine.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import AudioKit
import AudioToolbox
import Carbon.HIToolbox
import Combine
import Foundation
import SwiftUI

enum PlayMode {
    case perform, listen
}

class BardEngine {
    private let sequencer = AppleSequencer()
    private let instrument = MIDICallbackInstrument()
    private let controlInstrument = MIDICallbackInstrument()
    private let nullInstrument = MIDICallbackInstrument()
    private let sampler = MIDISampler()
    private let engine = AudioEngine()
    private let bardController = BardController()
    private var controlTrack: MusicTrackManager?
    private var musicTrack: MusicTrackManager?
    private var currentPositionTimer: Timer?

    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentPosition: Double = 0
    @Published private(set) var notesTransposed: Bool = false

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

    private func controlCallback(_ status: UInt8, _: MIDINoteNumber, _: MIDIVelocity) {
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

        // Mute all tracks that came with the MIDI file
        sequencer.setGlobalMIDIOutput(nullInstrument.midiIn)

        // Add our own music track which we will copy midi notes into
        musicTrack = sequencer.newTrack("music")
        musicTrack?.setMIDIOutput(instrument.midiIn)

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
        guard let musicTrack = musicTrack else { return }

        let wasPlaying = sequencer.isPlaying

        if wasPlaying {
            sequencer.stop()
        }

        // Load track into music track
        musicTrack.replaceMIDINoteData(with: track.midiNoteData)

        if track.transposeAmount != 0 {
            musicTrack.transposeNotes(semitones: track.transposeAmount)
        }

        notesTransposed = track.autoTransposeNotes
        if track.autoTransposeNotes {
            musicTrack.transposeOutOfBoundNotes()
        }

        if track.arpeggiateChords {
            musicTrack.arpeggiateChords()
        }

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

            currentPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
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

extension MusicTrackManager {
    private func transposeNote(_ noteNumber: MIDINoteNumber) -> MIDINoteNumber {
        if noteNumber < 48 {
            return transposeNote(noteNumber + 12)
        } else if noteNumber > 84 {
            return transposeNote(noteNumber - 12)
        }

        return noteNumber
    }

    func transposeOutOfBoundNotes() {
        var noteData: [MIDINoteData] = []

        for midiNote in getMIDINoteData() {
            let newMidiNote = MIDINoteData(
                noteNumber: transposeNote(midiNote.noteNumber),
                velocity: midiNote.velocity,
                channel: midiNote.channel,
                duration: midiNote.duration,
                position: midiNote.position
            )
            noteData.append(newMidiNote)
        }

        replaceMIDINoteData(with: noteData)
    }

    func transposeNotes(semitones: Int) {
        var noteData: [MIDINoteData] = []

        for midiNote in getMIDINoteData() {
            let newMidiNote = MIDINoteData(
                noteNumber: UInt8(Int(midiNote.noteNumber) + semitones),
                velocity: midiNote.velocity,
                channel: midiNote.channel,
                duration: midiNote.duration,
                position: midiNote.position
            )
            noteData.append(newMidiNote)
        }

        replaceMIDINoteData(with: noteData)
    }

    func arpeggiateChords() {
        // Group notes into chords according to beat
        /// [beat position: [...notes]]
        var chords: [Double: [MIDINoteData]] = [:]

        for midiNote in getMIDINoteData() {
            if chords[midiNote.position.beats] != nil {
                // It's possible for a chord to have the same note twice if the track was transposed
                // This if statement filters out those duplicate notes
                if !chords[midiNote.position.beats]!.contains(where: { $0.noteNumber == midiNote.noteNumber }) {
                    chords[midiNote.position.beats]?.append(midiNote)
                }
            } else {
                chords[midiNote.position.beats] = [midiNote]
            }
        }

        var noteData: [MIDINoteData] = []

        for (_, chord) in chords {
            for (index, midiNote) in chord.sorted(by: { $0.noteNumber < $1.noteNumber }).enumerated() {
                let newMidiNote = MIDINoteData(
                    noteNumber: midiNote.noteNumber,
                    velocity: midiNote.velocity,
                    channel: midiNote.channel,
                    duration: midiNote.duration,
                    position: midiNote.position + Duration(beats: Double(index) * 0.001)
                )
                noteData.append(newMidiNote)
            }
        }

        replaceMIDINoteData(with: noteData)
    }
}

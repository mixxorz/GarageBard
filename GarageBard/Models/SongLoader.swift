//
//  SongLoader.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import AppKit
import AudioKit
import AudioToolbox
import Combine
import Foundation

class Track: ObservableObject, Hashable, Identifiable, CustomStringConvertible {
    var id: UUID
    var name: String
    var midiNoteData: [MIDINoteData] = []

    @Published private(set) var transposeAmount: Int = 0
    @Published var autoTransposeNotes: Bool = true
    @Published var arpeggiateChords: Bool = true

    // Optional because some tracks may be empty
    var noteLowerBound: MIDINoteNumber?
    var noteUpperBound: MIDINoteNumber?

    var hasOutOfRangeNotes: Bool {
        guard let noteLowerBound = noteLowerBound, let noteUpperBound = noteUpperBound else { return false }
        return Int(noteLowerBound) + transposeAmount < 48 || Int(noteUpperBound) + transposeAmount > 84
    }

    var description: String { "Track: \(name) - \(id)" }

    init(id: UUID = UUID(), name: String, midiNoteData: [MIDINoteData] = []) {
        self.id = id
        self.name = name
        self.midiNoteData = midiNoteData

        let notes = midiNoteData.map(\.noteNumber)

        noteLowerBound = notes.min()
        noteUpperBound = notes.max()
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    private func getNoteName(note: MIDINoteNumber) -> String {
        // Middle C is 60 (C3)
        // Our range goes from 0 == C-2 to 127 == G8
        let octave = (Int(note) + 24) / 12 - 4
        let noteNumber = Int(note) - 21
        let notes: [String] = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]

        let noteIndex = noteNumber % 12

        let name: String
        if noteIndex >= 0 {
            name = notes[noteNumber % 12]
        } else {
            name = notes.suffix(abs(noteNumber % 12)).first!
        }

        return "\(name)\(octave)"
    }

    private func getNoteNumber(value: String) -> MIDINoteNumber? {
        let alphabet: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let allNotes = (0 ... 127).reduce(into: [String: MIDINoteNumber]()) { acc, num in
            let octave = (num + 24) / 12 - 4
            acc["\(alphabet[num % 12])\(octave)"] = MIDINoteNumber(num)
        }
        return allNotes[value.uppercased()]
    }

    func getTransposedDisplay() -> String {
        guard let noteLowerBound = noteLowerBound, let noteUpperBound = noteUpperBound else { return "-" }
        let lowerNoteName = getNoteName(note: UInt8(Int(noteLowerBound) + transposeAmount))
        let upperNoteName = getNoteName(note: UInt8(Int(noteUpperBound) + transposeAmount))
        let notesText = "\(lowerNoteName)–\(upperNoteName)"

        if transposeAmount > 0 {
            return String("\(notesText) +\(transposeAmount)")
        } else if transposeAmount < 0 {
            return String("\(notesText) \(transposeAmount)")
        }
        return notesText
    }

    func setTransposeAmount(semitones: Int) {
        guard let noteLowerBound = noteLowerBound, let noteUpperBound = noteUpperBound else { return }

        // Ensure that the new value doesn't cause notes to become invalid
        let newNoteLowerBound = Int(noteLowerBound) + semitones
        let newNoteUpperBound = Int(noteUpperBound) + semitones

        if newNoteLowerBound < 0 || newNoteUpperBound > 127 {
            return
        }

        transposeAmount = semitones
    }

    func setTransposeAmount(fromString value: String) {
        guard let noteLowerBound = noteLowerBound, let noteUpperBound = noteUpperBound else { return }

        let cleanedValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        if let semitones = Int(value) {
            setTransposeAmount(semitones: semitones)
        } else if let targetNote = getNoteNumber(value: cleanedValue) {
            var semitoneDifference = 0

            if !value.starts(with: "-") {
                semitoneDifference = Int(targetNote) - Int(noteLowerBound)
            } else {
                semitoneDifference = Int(targetNote) - Int(noteUpperBound)
            }
            setTransposeAmount(semitones: semitoneDifference)
        }
    }
}

class Song: ObservableObject, Identifiable, Equatable, CustomStringConvertible {
    let id: UUID
    let name: String
    let url: URL
    let durationInSeconds: Double
    let tracks: [Track]

    var description: String { "Song: \(name) - \(id)" }

    init(name: String, url: URL, durationInSeconds: Double, tracks: [Track]) {
        id = UUID()
        self.name = name
        self.url = url
        self.durationInSeconds = durationInSeconds
        self.tracks = tracks
    }

    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

class SongLoader {
    /// Loads a MIDI song from a URL
    func openSong(fromURL url: URL) -> Song {
        let sequencer = AppleSequencer()

        do {
            let data = try Data(contentsOf: url)
            sequencer.loadMIDIFile(fromData: data)
        } catch {
            fatalError("Error opening file: \(error)")
        }

        // Load tracks
        let tracks: [Track] = sequencer.tracks.filter { $0.getMIDINoteData().count > 0 }.enumerated().map { index, track in
            Track(
                id: UUID(),
                name: track.getTrackName() ?? "Track \(index + 1)",
                midiNoteData: track.getMIDINoteData()
            )
        }

        return Song(
            name: url.lastPathComponent,
            url: url,
            durationInSeconds: sequencer.seconds(duration: ceil(sequencer.length)),
            tracks: tracks
        )
    }

    /// Opens a dialog to select a song
    func openLoadSongDialog() -> Song? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.midi]

        if panel.runModal() == .OK {
            if let url = panel.url {
                return openSong(fromURL: url)
            }
        }

        return nil
    }
}

/// Helper for accessing the data of `MIDIMetaEvent`.
///
/// Copied from AudioKit
struct UnsafeMIDIMetaEventPointer {
    let event: UnsafePointer<MIDIMetaEvent>
    let payload: UnsafeBufferPointer<UInt8>

    init?(_ pointer: UnsafeRawBufferPointer) {
        guard let baseAddress = pointer.baseAddress else {
            return nil
        }
        self.init(baseAddress)
    }

    init?(_ pointer: UnsafeRawPointer?) {
        guard let pointer = pointer else {
            return nil
        }
        self.init(pointer)
    }

    init(_ pointer: UnsafeRawPointer) {
        let event = pointer.bindMemory(to: MIDIMetaEvent.self, capacity: 1)
        let offset = MemoryLayout<MIDIMetaEvent>.offset(of: \MIDIMetaEvent.data)!
        let dataLength = Int(event.pointee.dataLength)
        let dataPointer = pointer.advanced(by: offset).bindMemory(to: UInt8.self, capacity: dataLength)
        self.event = event
        payload = UnsafeBufferPointer(start: dataPointer, count: dataLength)
    }
}

extension MusicTrackManager {
    func getTrackName() -> String? {
        guard let eventData = eventData else { return nil }

        var potentialNames: [String] = []

        for event in eventData {
            if event.type == kMusicEventType_Meta {
                let metaEventPointer = UnsafeMIDIMetaEventPointer(event.data)!
                let metaEvent = metaEventPointer.event.pointee
                if metaEvent.metaEventType == MIDICustomMetaEventType.trackName.rawValue {
                    let data = Data(buffer: metaEventPointer.payload)
                    if let str = String(data: data, encoding: String.Encoding.utf8) {
                        potentialNames.append(str.trimmingCharacters(in: .whitespaces))
                    }
                }
            }
        }

        for name in potentialNames {
            if name != "", name != "InitializedTrack" {
                return name
            }
        }

        return nil
    }
}

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

struct Track: Hashable, Identifiable {
    var id: Int
    var name: String
    var midiNoteData: [MIDINoteData] = []

    // Optional because some tracks may be empty
    var noteLowerBound: MIDINoteNumber?
    var noteUpperBound: MIDINoteNumber?

    var hasOutOfRangeNotes: Bool {
        guard let noteLowerBound = noteLowerBound, let noteUpperBound = noteUpperBound else { return false }
        return noteLowerBound < 48 || noteUpperBound > 84
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

class Song: ObservableObject, Identifiable {
    let id: String
    let name: String
    let url: URL
    let durationInSeconds: Double
    let tracks: [Track]

    @Published var autoTranposeNotes: Bool
    @Published var arpeggiateChords: Bool

    init(name: String, url: URL, durationInSeconds: Double, tracks: [Track], autoTranposeNotes: Bool = true, arpeggiateChords: Bool = true) {
        id = name
        self.name = name
        self.url = url
        self.durationInSeconds = durationInSeconds
        self.tracks = tracks
        self.autoTranposeNotes = autoTranposeNotes
        self.arpeggiateChords = arpeggiateChords
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
        var tracks: [Track] = sequencer.tracks.enumerated().map { index, track in
            let trackName = track.getTrackName() ?? "Track \(index + 1)"
            let notes = track.getMIDINoteData().map(\.noteNumber)
            let noteLowerBound = notes.min()
            let noteUpperBound = notes.max()

            return Track(
                id: index, // It's important that this is the index according to the sequencer
                name: trackName,
                midiNoteData: track.getMIDINoteData(),
                noteLowerBound: noteLowerBound,
                noteUpperBound: noteUpperBound
            )
        }

        // Filter out empty tracks
        tracks = tracks.filter { $0.midiNoteData.count > 0 }

        return Song(
            name: url.lastPathComponent,
            url: url,
            durationInSeconds: sequencer.seconds(duration: sequencer.length),
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
        if let eventData = eventData {
            for event in eventData {
                if event.type == kMusicEventType_Meta {
                    let metaEventPointer = UnsafeMIDIMetaEventPointer(event.data)!
                    let metaEvent = metaEventPointer.event.pointee
                    if metaEvent.metaEventType == MIDICustomMetaEventType.trackName.rawValue {
                        let data = Data(buffer: metaEventPointer.payload)
                        if let str = String(data: data, encoding: String.Encoding.utf8) {
                            return str
                        }
                    }
                }
            }
        }

        return nil
    }
}

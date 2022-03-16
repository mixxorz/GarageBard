//
//  SongLoader.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import AppKit
import AudioKit
import Combine
import Foundation
import MidiParser

struct Track: Hashable, Identifiable {
    var id: Int
    var name: String
    var hasOutOfRangeNotes: Bool = false
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
        let midi = MidiData()
        let sequencer = AppleSequencer()

        do {
            let data = try Data(contentsOf: url)
            midi.load(data: data)
            sequencer.loadMIDIFile(fromData: data)
        } catch {
            fatalError("Error opening file: \(error)")
        }

        // Load track options
        let tracks: [Track] = midi.noteTracks.enumerated().map { index, track in
            var hasOutOfRangeNotes = false

            if sequencer.tracks.indices.contains(index) {
                let sTrack = sequencer.tracks[index]

                let outOfRangeNotes = sTrack.getMIDINoteData().filter { note in
                    note.noteNumber < 48 || note.noteNumber > 84
                }

                if outOfRangeNotes.count > 0 {
                    hasOutOfRangeNotes = true
                }
            }

            if track.name != "" {
                return Track(id: index, name: track.name, hasOutOfRangeNotes: hasOutOfRangeNotes)
            }

            return Track(id: index, name: "Track " + String(index), hasOutOfRangeNotes: hasOutOfRangeNotes)
        }

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

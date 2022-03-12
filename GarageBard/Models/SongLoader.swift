//
//  SongLoader.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import Foundation
import AudioKit
import MidiParser

struct Track: Hashable, Identifiable {
    var id: Int
    var name: String
}

struct Song: Identifiable, Equatable {
    var id: String { self.name }
    var name: String
    var url: URL
    var durationInSeconds: Double
    var tracks: [Track]
}

class SongLoader {
   
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
        let tracks: [Track] = midi.noteTracks.enumerated().map { (index, track) in
            if (track.trackName != "") {
                return Track(id: index, name: track.trackName)
            }
            return Track(id: index, name: "Track " + String(index))
        }
        
        return Song(
            name: url.lastPathComponent,
            url: url,
            durationInSeconds: sequencer.seconds(duration: sequencer.length),
            tracks: tracks
        )
    }
}

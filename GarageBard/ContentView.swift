//
//  ContentView.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/4/22.
//

import Combine
import SwiftUI
import MidiParser
import AudioKit
import AudioKitEX

func space(_ value: Int) -> CGFloat {
    return CGFloat(value * 4)
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.white))
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(.blue))
                    .animation(.linear, value: value)
            }
            .cornerRadius(45.0)
        }
    }
}

enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

struct PlayButton: View {
    var isPlaying: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 48.0))
                .padding(.horizontal, space(5))
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct PlayerView: View {
    @State var progressValue: Float = 0.5
    @Binding var isPlaying: Bool
    
    var songName : String
    var tracks: [Track] = []
    @Binding var selectedTrack: Track
    var tempo: Int
    
    var onPlay: () -> Void
    
    var body: some View {
        VStack {
            Text(songName)
                .font(.system(size: 16.0))
                .padding(.vertical, space(1))
            ProgressBar(value: $progressValue)
                .frame(height: space(2))
                .padding(.horizontal, space(5))
                .padding(.vertical, space(1))
            HStack {
                Picker(
                    "Filter",
                    selection: $selectedTrack,
                    content: {
                        ForEach(tracks) { track in
                            Text(track.name.capitalized)
                                .tag(track)
                        }
                    }
                )
                    .frame(width: space(30))
                PlayButton(isPlaying: isPlaying, action: {
                    isPlaying.toggle()
                    
                    if isPlaying {
                        onPlay()
                    }
                })
                Text(String(tempo) + " BPM")
                    .frame(width: space(15))
            }
        }
        .padding(.vertical, space(5))
    }
}


class OldPlayer: ObservableObject {
    var engine: AudioEngine
    var sequencer: AppleSequencer
    var sampler: MIDISampler
    var instrument: MIDICallbackInstrument
    @Published private(set) var message: String
    
    init() {
        engine = AudioEngine()
        sequencer = AppleSequencer()
        sampler = MIDISampler()
        instrument = MIDICallbackInstrument()
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        message = "Starting"
        try? engine.start()
        instrument.callback = noteCallback
    }
    
    private func noteCallback(_ status: UInt8, _ note: MIDINoteNumber, _ velocity: MIDIVelocity) {
        let mstat = MIDIStatusType.from(byte: status)
        if mstat == .noteOn {
            sampler.play(noteNumber: note, velocity: velocity, channel: 1)
            message = String(note)
        } else if mstat == .noteOff {
            sampler.stop(noteNumber: note, channel: 1)
        }
    }
    
    func selectSong(name: String, track: Int) {
        guard let asset = NSDataAsset(name: name) else {
            fatalError("Missing data asset")
        }
        let data: Data = asset.data
        sequencer.stop()
        sequencer.loadMIDIFile(fromData: data)
        sequencer.rewind()
        sequencer.preroll()
        message = "Song selected: \(name) - Track \(track)"
    }
    
    func play() {
        sequencer.play()
    }
}

struct ContentView: View {
    @State private var isPlaying = false
    @State private var songName : String = ""
    @State private var tracks: [Track] = []
    @State private var selectedTrack: Track = Track(id: 0, name: "None")
    @State private var tempo: Int = 120
    @State private var notes: [String] = []
    
    @ObservedObject private var player: OldPlayer = OldPlayer()
    
    func trackChanged(to track: Track) {
        player.selectSong(name: songName, track: track.id)
    }
    
    var body: some View {
        VStack() {
            PlayerView(
                isPlaying: $isPlaying,
                songName: songName,
                tracks: tracks,
                selectedTrack: $selectedTrack.onChange(trackChanged),
                tempo: tempo,
                onPlay: {
                    player.play()
                }
            )
            List {
                ForEach(notes, id: \.self) {note in
                    Text(note)
                }
            }
            Spacer()
        }
        .frame(width: space(100), height: space(150))
        .onAppear {
            songName = "still-alive"
            
            let midi = MidiData()
            guard let asset = NSDataAsset(name: songName) else {
                fatalError("Missing data asset")
            }
            let data: Data = asset.data
            midi.load(data: data)
            
            // Load tempo
            tempo = midi.infoDictionary[.tempo] as! Int
            
            // Load track options
            tracks = midi.noteTracks.enumerated().map { (index, track) in
                if (track.trackName != "") {
                    return Track(id: index, name: track.trackName, track: track)
                }
                return Track(id: index, name: "Track " + String(index), track: track)
            }
            selectedTrack = tracks[0]
            
            player.selectSong(name: songName, track: 0)
            player.$message.sink { message in
                notes.append(message)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

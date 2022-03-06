//
//  ContentView.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/4/22.
//

import Combine
import SwiftUI

func space(_ value: Int) -> CGFloat {
    return CGFloat(value * 4)
}

struct ContentView: View {
    @ObservedObject var model = PlayerViewModel()
    
    @State var isTrackPopoverOpen = false
    
    let tracks = [
        "Track 1",
        "Track 2",
        "Track 3",
        "Track 4",
        "Track 5",
        "Track 6",
        "Track 7",
        "Track 8",
        "Track 9",
        "Track 10",
        "Track 11",
        "Track 12",
        "Track 13",
        "Track 14",
        "Track 15",
        "Track 16",
    ]

    var body: some View {
        ZStack {
            Color("grey600")
            VStack {
                VStack {
                    HStack(alignment: .bottom) {
                        Text("1:02")
                            .font(.system(size: 10.0))
                        Spacer()
                        Text(model.song?.name ?? "No song selected")
                            .font(.system(size: 14.0))
                            .foregroundColor(.white)
                        Spacer()
                        Text("-2:51")
                            .font(.system(size: 10.0))
                    }
                    ProgressBar(value: 0.5)
                        .frame(height: space(1))
                    HStack(spacing: space(4)) {
    //                    Picker(
    //                        "Filter",
    //                        selection: $model.track,
    //                        content: {
    //                            ForEach(model.song?.tracks ?? []) { track in
    //                                Text(track.name).tag(track as Track?)
    //                            }
    //                        }
    //                    )
    //                        .frame(width: space(35))
                        Button(action: { self.isTrackPopoverOpen = true }) {
                            Image(systemName: "pianokeys")
                                .font(.system(size: 20.0))
                                .foregroundColor(Color("grey400"))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .popover(isPresented: $isTrackPopoverOpen, content: {
                            List {
                                Section {
                                    Label("Track 1", systemImage: "pianokeys")
                                    Label("Track 2", systemImage: "pianokeys")
                                    Label("Track 3", systemImage: "pianokeys")
                                    Label("Track 4", systemImage: "pianokeys")
                                    Label("Track 5", systemImage: "pianokeys")
                                    Label("Track 6", systemImage: "pianokeys")
                                    Label("Track 7", systemImage: "pianokeys")
                                }
                            }
                        })
                        Spacer()
                        Button(action: {
                            model.playOrPause()
                        }) {
                            Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20.0))
                                .foregroundColor(Color("grey400"))
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            model.stop()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 20.0))
                                .foregroundColor(Color("grey400"))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20.0))
                            .foregroundColor(Color("grey400"))
                    }
                    .padding(.vertical, space(2))
                }
                .padding(space(4))
                .foregroundColor(Color("grey400"))
                ZStack {
                    Color("grey700")
                    ScrollView {
                        VStack {
                            PlaylistItemRow(
                                name: "Still Alive",
                                action: {
                                    model.loadSongFromName(songName: "still-alive")
                            })
                            PlaylistItemRow(
                                name: "For Sure - Sax",
                                action: {
                                    model.loadSongFromName(songName: "for-sure-sax")
                            })
                            PlaylistItemRow(
                                name: "For Sure - All",
                                action: {
                                    model.loadSongFromName(songName: "for-sure-all")
                            })
                        }
                        .padding(space(4))
                    }
                }
                
//                HStack {
//                    Button(action: {
//                        model.loadSongFromName(songName: "still-alive")
//                    }) {
//                        Text("Still alive")
//                    }
//                    Button(action: {
//                        model.loadSongFromName(songName: "for-sure-sax")
//                    }) {
//                        Text("For sure - Sax")
//                    }
//                    Button(action: {
//                        model.loadSongFromName(songName: "for-sure-all")
//                    }) {
//                        Text("For sure - All")
//                    }
//                }
            }
        }
        .frame(width: space(100), height: space(150))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

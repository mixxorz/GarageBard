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
    
    var body: some View {
        VStack {
            VStack {
                Text(model.song?.name ?? "No song selected")
                    .font(.system(size: 16.0))
                    .padding(.vertical, space(1))
                ProgressBar(value: 0.5)
                    .frame(height: space(2))
                    .padding(.horizontal, space(5))
                    .padding(.vertical, space(1))
                HStack {
                    Picker(
                        "Filter",
                        selection: $model.track,
                        content: {
                            ForEach(model.song?.tracks ?? []) { track in
                                Text(track.name.capitalized)
                                    .tag(track)
                            }
                        }
                    )
                        .frame(width: space(30))
                    PlayButton(
                        isPlaying: model.isPlaying,
                        action: model.playOrPause
                    )
                    Text("120 BPM")
                        .frame(width: space(15))
                }
                HStack {
                    Button(action: {
                        model.loadSongFromName(songName: "still-alive")
                    }) {
                        Text("Still alive")
                    }
                    Button(action: {
                        model.loadSongFromName(songName: "for-sure-sax")
                    }) {
                        Text("For sure - Sax")
                    }
                    Button(action: {
                        model.loadSongFromName(songName: "for-sure-all")
                    }) {
                        Text("For sure - All")
                    }
                }
            }
            .padding(.vertical, space(5))
        }
        .frame(width: space(100), height: space(150))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

//
//  PlayerBar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct PlayerBar<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    @State var isTrackPopoverOpen = false
    
    let formatter = TimeFormatter.instance
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(model.currentProgress > 0 ? formatter.format(model.currentPosition) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(16), alignment: .leading)
                Spacer()
                Text(model.song?.name ?? "No song selected")
                    .font(.system(size: 14.0))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                Text(model.currentProgress > 0 ? formatter.format(model.timeLeft) : "")
                    .font(.system(size: 10.0))
                    .frame(width: space(16), alignment: .trailing)
            }
            ProgressBar(value: model.currentProgress)
                .frame(height: space(1))
            HStack(spacing: space(4)) {
                Button(action: { self.isTrackPopoverOpen = true }) {
                    Image(systemName: "pianokeys")
                        .font(.system(size: 20.0))
                        .foregroundColor(Color("grey400"))
                }
                .buttonStyle(BorderlessButtonStyle())
                .popover(
                    isPresented: $isTrackPopoverOpen,
                    arrowEdge: .bottom,
                    content: {
                        TrackPopover<Model>(tracks: model.song?.tracks ?? [])
                    }
                )
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
        .padding(.top, space(4))
        .foregroundColor(Color("grey400"))
    }
}

struct PlayerBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerBar<FakePlayerViewModel>()
            .preferredColorScheme(.dark)
            .environmentObject(FakePlayerViewModel(song: nil, track: nil, isPlaying: true, currentProgress: 0.8))
            .frame(maxWidth: space(100))
        
        PlayerBar<FakePlayerViewModel>()
            .preferredColorScheme(.dark)
            .environmentObject(
                FakePlayerViewModel(
                    song: Song(
                        name: "This is a really long song title that breaks into multiple lines",
                        durationInSeconds: 123.0,
                        tracks: []
                    ),
                    track: nil,
                    isPlaying: true,
                    currentProgress: 0.8
                )
            )
            .frame(maxWidth: space(100))
    }
}

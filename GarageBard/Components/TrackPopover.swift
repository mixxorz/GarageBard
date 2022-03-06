//
//  TrackPopover.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct Row: View {
    @EnvironmentObject var model: PlayerViewModel
    
    @State var isHovering: Bool = false
    
    var track: Track
    var selected: Bool
    
    var body: some View {
        Button(action: {
            model.setTrack(track: track)
        }) {
            HStack {
                Text(track.name.capitalized)
                Spacer()
                if selected {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, space(2))
        .padding(.horizontal, space(1))
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: space(1), style: .continuous)
                .fill(isHovering ? Color.accentColor : Color.clear)
        )
        .foregroundColor(isHovering ? Color.primary : Color("grey400"))
        .onHover { hovering in
            isHovering = hovering
        }
    }
}


struct TrackPopover<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    var tracks: [Track]
    
    var body: some View {
        VStack {
            if tracks.isNotEmpty {
                VStack(spacing: 0) {
                    ForEach(tracks.indices) { index in
                        let track = tracks[index]
                        VStack(spacing: 0) {
                            if (index != 0) {
                                Divider()
                            }
                            Row(track: track, selected: model.track == track)
                                .padding(.horizontal, -space(1))
                        }
                        .padding(.horizontal, space(1))
                    }
                }
                .frame(minWidth: space(38))
            } else {
                Text("No tracks")
                    .padding(space(1))
            }
        }
        .padding(space(1))
    }
}

struct TrackPopover_Previews: PreviewProvider {
    static var previews: some View {
        TrackPopover<FakePlayerViewModel>(tracks: [
            Track(id: 0, name: "Saxophone"),
            Track(id: 1, name: "Guitar"),
            Track(id: 2, name: "Lute"),
            Track(id: 3, name: "Drum Kit"),
            Track(id: 4, name: "Electric Guitar"),
            Track(id: 5, name: "Violin")
        ])
            .environmentObject(FakePlayerViewModel())
    }
}

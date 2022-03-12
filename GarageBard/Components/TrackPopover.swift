//
//  TrackPopover.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct TrackPopover<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    
    var tracks: [Track]
    
    var body: some View {
        VStack {
            if tracks.isNotEmpty {
                PopoverMenu {
                    ForEach(tracks) { track in
                        PopoverMenuItem(action: { vm.track = track }) {
                            Text(track.name.capitalized)
                            Spacer()
                            if vm.track == track {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                        }
                    }
                }
            } else {
                Text("No tracks")
                    .padding(space(2))
            }
        }
        .foregroundColor(Color.primary)
    }
}

struct TrackPopover_Previews: PreviewProvider {
    static let song = Song(
        name: "My Song",
        durationInSeconds: 150.0,
        tracks: [
            Track(id: 0, name: "Saxophone"),
            Track(id: 1, name: "Guitar"),
            Track(id: 2, name: "Lute"),
            Track(id: 3, name: "Drum Kit"),
            Track(id: 4, name: "Electric Guitar"),
            Track(id: 5, name: "Violin")
        ]
    )
    
    static var previews: some View {
        TrackPopover<FakePlayerViewModel>(tracks: song.tracks)
            .frame(width: 200)
            .preferredColorScheme(.light)
            .environmentObject(
                FakePlayerViewModel(
                    song: song,
                    track: song.tracks[1]
                )
            )
        
        TrackPopover<FakePlayerViewModel>(tracks: song.tracks)
            .frame(width: 200)
            .preferredColorScheme(.dark)
            .environmentObject(
                FakePlayerViewModel(
                    song: song,
                    track: song.tracks[1]
                )
            )
    }
}

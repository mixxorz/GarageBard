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

struct ContentView<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        ZStack {
            Color("grey600")
            VStack {
                PlayerBar<ViewModel>()
                SongLibrary<ViewModel>()
            }
            .overlay {
                Notifications<ViewModel>()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: space(100), height: space(150))
    }
}

struct ContentView_Previews: PreviewProvider {
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
        Group {
            ContentView<FakePlayerViewModel>()
                .preferredColorScheme(.dark)
                .environmentObject(
                    FakePlayerViewModel(
                        song: song, track: song.tracks[0]
                    )
                )
        }
    }
}

//
//  SubToolbar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/18/22.
//

import SwiftUI

struct SubToolbar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    var body: some View {
        HStack {
            if let track = vm.track {
                TransposeField<ViewModel>(track: track)
                AutoTransposeNotesField<ViewModel>(track: track)
                ArpeggiateChordsField<ViewModel>(track: track)

                Spacer()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .foregroundColor(Color("grey500"))
                        .frame(width: space(30), height: space(6))

                    Text("No track loaded")
                }
            }
        }
    }
}

struct SubToolbar_Previews: PreviewProvider {
    static var song = createSong()

    static var previews: some View {
        SubToolbar<FakePlayerViewModel>()
            .foregroundColor(Color("grey400"))
            .environmentObject(FakePlayerViewModel())
            .frame(width: space(100))
            .padding(space(4))
            .background(Color("grey600"))

        SubToolbar<FakePlayerViewModel>()
            .foregroundColor(Color("grey400"))
            .environmentObject(FakePlayerViewModel(song: song, track: song.tracks.first))
            .frame(width: space(100))
            .padding(space(4))
            .background(Color("grey600"))
    }
}

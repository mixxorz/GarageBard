//
//  SongLibrary.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import SwiftUI

struct SongLibrary<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        ZStack {
            Color("grey700")
            ScrollView {
                VStack {
                    ForEach(vm.songs) { song in
                        PlaylistItemRow<ViewModel>(song: song)
                    }
                }
                .padding(space(4))
            }
        }
    }
}

struct SongLibrary_Previews: PreviewProvider {
    static var previews: some View {
        SongLibrary<FakePlayerViewModel>()
            .frame(maxWidth: space(100))
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}

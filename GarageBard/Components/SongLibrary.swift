//
//  SongLibrary.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import CoreMIDI
import SwiftUI
import UniformTypeIdentifiers

struct MIDIDropDelegate<ViewModel: PlayerViewModelProtocol>: DropDelegate {
    var vm: ViewModel

    @Binding var isDropping: Bool

    func dropEntered(info _: DropInfo) {
        withAnimation(.spring()) {
            isDropping = true
        }
    }

    func dropExited(info _: DropInfo) {
        withAnimation(.spring()) {
            isDropping = false
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [.fileURL]).filter { provider in
            provider.canLoadObject(ofClass: URL.self)
        }

        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { object, _ in
                if let url = object {
                    DispatchQueue.main.async {
                        if let uttype = UTType(filenameExtension: url.pathExtension) {
                            if uttype.conforms(to: .midi) {
                                vm.loadSong(fromURL: url)
                            }
                        }
                    }
                }
            }
        }

        return providers.count > 0
    }
}

struct SongLibrary<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    @State var isDropping: Bool = false

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
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay {
            if isDropping {
                VStack {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 60))
                            .offset(x: 0, y: -5)
                    }
                    .frame(width: space(28), height: space(28))
                    .background(
                        Color("grey400")
                            .opacity(0.15)
                            .cornerRadius(8)
                    )
                    .foregroundColor(.white)
                    .offset(x: 0, y: space(20))
                    Spacer()
                }
            }
        }
        .onDrop(of: [.fileURL], delegate: MIDIDropDelegate<ViewModel>(vm: vm, isDropping: $isDropping))
    }
}

struct SongLibrary_Previews: PreviewProvider {
    static let vm = FakePlayerViewModel(
        song: nil,
        track: nil,
        songs: [
            createSong(name: "Song 1"),
            createSong(name: "Song 2"),
            createSong(name: "Song 3"),
            createSong(name: "Song 4"),
            createSong(name: "Song 5"),
            createSong(name: "Song 6"),
        ]
    )

    static var previews: some View {
        SongLibrary<FakePlayerViewModel>()
            .frame(maxWidth: space(100))
            .environmentObject(vm)
    }
}

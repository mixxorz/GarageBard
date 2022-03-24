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

struct SongDropDelegate<ViewModel: PlayerViewModelProtocol>: DropDelegate {
    var vm: ViewModel

    let song: Song
    @Binding var dragItem: Song?
    @Binding var hasChangedLocation: Bool

    func performDrop(info _: DropInfo) -> Bool {
        dragItem = nil
        hasChangedLocation = false
        return true
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info _: DropInfo) {
        guard let dragItem = dragItem else { return }
        guard let from = vm.songs.firstIndex(of: dragItem), let to = vm.songs.firstIndex(of: song) else { return }

        if dragItem != song {
            hasChangedLocation = true

            withAnimation(.spring()) {
                vm.songs.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}

struct SongDropOutsideDelegate: DropDelegate {
    @Binding var dragItem: Song?
    @Binding var hasChangedLocation: Bool

    func dropEntered(info _: DropInfo) {
        hasChangedLocation = true
    }

    func performDrop(info _: DropInfo) -> Bool {
        hasChangedLocation = false
        dragItem = nil
        return true
    }
}

struct SongLibrary<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    // MIDI file drop
    @State var isFileDropping: Bool = false

    // Song drag and drop
    @State var isSongDropping: Bool = false
    @State var dragItem: Song? = nil
    @State var hasChangedLocation: Bool = false

    var body: some View {
        ZStack {
            Color("grey700")
            ScrollView {
                VStack {
                    ForEach(vm.songs) { song in
                        PlaylistItemRow<ViewModel>(song: song)
                            .opacity(dragItem == song && hasChangedLocation ? 0 : 1)
                            .onDrag({
                                dragItem = song
                                return NSItemProvider(object: song.description as NSString)

                            }, preview: {
                                Text(song.name)
                                    .lineLimit(1)
                                    .foregroundColor(Color.primary)
                                    .padding(space(1))
                                    .background(RoundedRectangle(cornerRadius: space(1), style: .continuous).foregroundColor(Color.accentColor))
                            })
                            .onDrop(of: [.text], delegate: SongDropDelegate<ViewModel>(vm: vm, song: song, dragItem: $dragItem, hasChangedLocation: $hasChangedLocation))
                    }
                }
                .padding(space(4))
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            if dragItem == nil {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .onDrop(of: [.fileURL], delegate: MIDIDropDelegate<ViewModel>(vm: vm, isDropping: $isFileDropping))
            }
        }
        .overlay {
            if isFileDropping {
                VStack {
                    VStack {
                        Image(systemName: "text.append")
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
        .onDrop(of: [.text], delegate: SongDropOutsideDelegate(dragItem: $dragItem, hasChangedLocation: $hasChangedLocation))
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

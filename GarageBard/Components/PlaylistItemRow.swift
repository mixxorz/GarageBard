//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct PlaylistItemRow<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var song: Song
    @State var isSongPopoverOpen: Bool = false
    
    let formatter = TimeFormatter.instance
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring()) {
                        vm.song = song
                    }
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 10.0))
                        .foregroundColor(Color("grey400"))
                        .frame(width: space(8), height: space(8))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Text(song.name)
                    .foregroundColor(Color.white)
                Spacer()
                Text(formatter.format(song.durationInSeconds))
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
                Button(action: {
                    isSongPopoverOpen = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 10.0))
                        .foregroundColor(Color("grey400"))
                        .frame(width: space(8), height: space(8))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isSongPopoverOpen, arrowEdge: .bottom) {
                    PopoverMenu {
                        PopoverMenuItem(action: {
                            song.autoTranposeNotes.toggle()
                        }) {
                            Text("Tranpose out of range notes")
                            Spacer()
                            if song.autoTranposeNotes {
                                Image(systemName: "checkmark")
                            }
                        }
                        PopoverMenuItem(action: {
                            song.arpeggiateChords.toggle()
                        }) {
                            Text("Arpeggiate chords")
                            Spacer()
                            if song.arpeggiateChords {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Divider()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            withAnimation(.spring()) {
                vm.song = song
            }
        })
    }
}

struct PlaylistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemRow<FakePlayerViewModel>(song: createSong())
            .frame(maxWidth: space(100))
            .padding(.horizontal, space(4))
            .preferredColorScheme(.dark)
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}

//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct PlayingBars: View {
    @State var modifier: Double = 1.0

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .frame(height: space(10) * modifier)
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(), value: modifier)
            RoundedRectangle(cornerRadius: 4)
                .frame(height: space(10) * modifier, alignment: .bottom)
                .animation(Animation.easeInOut(duration: 0.37).repeatForever(), value: modifier)
            RoundedRectangle(cornerRadius: 4)
                .frame(height: space(10) * modifier, alignment: .bottom)
                .animation(Animation.easeInOut(duration: 0.45).repeatForever(), value: modifier)
            RoundedRectangle(cornerRadius: 4)
                .frame(height: space(10) * modifier, alignment: .bottom)
                .animation(Animation.easeInOut(duration: 0.54).repeatForever(), value: modifier)
        }
        .frame(width: space(12), height: space(10), alignment: .bottom)
        .scaledToFit()
        .onAppear {
            modifier = 0.40
        }
    }
}

struct PlaylistItemRow<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var song: Song

    @State var isHovering = false
    @State var isPopoverOpen = false

    let formatter = TimeFormatter.instance

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                if vm.song == song {
                    if vm.isPlaying {
                        if isHovering {
                            Button(action: {
                                vm.playOrPause()
                            }) {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 12.0))
                                    .foregroundColor(Color.accentColor)
                                    .frame(width: space(8), height: space(8))
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            PlayingBars()
                                .scaleEffect(3 / 10)
                                .frame(width: space(8), height: space(8))
                                .foregroundColor(Color.accentColor)
                        }
                    } else {
                        Button(action: {
                            vm.playOrPause()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12.0))
                                .foregroundColor(Color.accentColor)
                                .frame(width: space(8), height: space(8))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                } else {
                    Button(action: {
                        withAnimation(.spring()) {
                            vm.song = song
                        }
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 12.0))
                            .foregroundColor(Color("grey400"))
                            .frame(width: space(8), height: space(8))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Text(song.name)
                    .foregroundColor(Color.white)
                Spacer()
                Text(formatter.format(song.durationInSeconds))
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
                Button(action: {
                    isPopoverOpen.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12.0))
                        .foregroundColor(Color("grey400"))
                        .frame(width: space(8), height: space(8))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .popover(
                    isPresented: $isPopoverOpen,
                    arrowEdge: .bottom,
                    content: {
                        PopoverMenu {
                            PopoverMenuItem(action: {
                                vm.removeSong(song: song)
                            }) {
                                Text("Remove")
                                Spacer()
                            }
                        }
                    }
                )
            }
            Divider()
        }
        .onHover { hovering in
            withAnimation(Animation.linear(duration: 0.2)) {
                isHovering = hovering
            }
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

//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI


class TimeFormatter {
    let formatter = DateComponentsFormatter()
    
    static let instance = TimeFormatter()
    
    init() {
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
    }
    
    func format(_ duration: Double) -> String {
        guard let str = formatter.string(from: duration) else {
            return ""
        }
        
        // Drop leading minute zero
        if str.hasPrefix("0") && str.count > 4 {
            return String(str.dropFirst())
        }
        
        return str
    }
}


struct PlaylistItemRow<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    var song: Song
    
    let formatter = TimeFormatter.instance
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Button(action: {
                    model.setSong(song: song)
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
            }
            Divider()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            model.setSong(song: song)
        })
    }
}

struct PlaylistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemRow<FakePlayerViewModel>(song: Song(name: "Flow - Final Fantasy XIV", durationInSeconds: 200.0, tracks: []))
            .frame(maxWidth: space(100))
            .padding(.horizontal, space(4))
            .preferredColorScheme(.dark)
            .environmentObject(FakePlayerViewModel(song: nil, track: nil))
    }
}
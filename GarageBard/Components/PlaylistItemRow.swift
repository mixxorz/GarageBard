//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct PlaylistItemRow: View {
    var name: String
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Button(action: action) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 10.0))
                        .foregroundColor(Color("grey400"))
                        .frame(width: space(8), height: space(8))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Text(name)
                    .foregroundColor(Color.white)
                Spacer()
                Text("2:45")
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
            }
            Divider()
        }
    }
}

struct PlaylistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemRow(name: "Flow - Final Fantasy XIV", action: {})
            .frame(maxWidth: space(100))
            .padding(.horizontal, space(4))
            .preferredColorScheme(.dark)
    }
}

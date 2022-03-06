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
            HStack {
                Button(action: action) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 10.0))
                        .foregroundColor(Color("grey400"))
                }
                .buttonStyle(.plain)
                Text(name)
                    .foregroundColor(Color.white)
                Spacer()
                Text("2:45")
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
            }
            .padding(.vertical, space(2))
            Divider()
        }
    }
}

struct PlaylistItemRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItemRow(name: "Flow - Final Fantasy XIV", action: {})
    }
}

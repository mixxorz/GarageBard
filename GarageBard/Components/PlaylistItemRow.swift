//
//  PlaylistItemRow.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import SwiftUI

struct PlaylistItemRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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
        PlaylistItemRow()
    }
}

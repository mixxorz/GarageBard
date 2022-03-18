//
//  PlayerButton.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/18/22.
//

import SwiftUI

struct PlayerButton: View {
    var action: () -> Void
    var iconName: String

    @State var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .frame(width: space(8), height: space(7))
                    .foregroundColor(.white)
                    .opacity(isHovering ? 0.1 : 0)
                Image(systemName: iconName)
                    .font(.system(size: 20.0))
                    .foregroundColor(Color("grey400"))
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PlayerButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayerButton(action: {}, iconName: "dial.max")
            .padding(space(4))
            .background(Color("grey600"))

        PlayerButton(action: {}, iconName: "dial.max", isHovering: true)
            .padding(space(4))
            .background(Color("grey600"))
    }
}

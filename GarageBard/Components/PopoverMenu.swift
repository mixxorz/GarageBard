//
//  PopoverMenu.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import SwiftUI

struct PopoverMenuItem<Content: View>: View {
    @State var isHovering: Bool = false
    
    var action: () -> Void
    var content: () -> Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            HStack(content: content)
                .padding(space(1))
                .contentShape(RoundedRectangle(cornerRadius: space(1), style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: space(1), style: .continuous)
                .fill(isHovering ? Color.accentColor : Color.clear)
        )
        .foregroundColor(isHovering ? Color.white : Color.primary)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PopoverMenu<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0, content: content)
        .foregroundColor(Color.primary)
        .frame(minWidth: space(38))
        .padding(6)
    }
}

struct PopoverMenu_Previews: PreviewProvider {
    static var previews: some View {
        PopoverMenu {
            PopoverMenuItem(action: {}) {
                Text("Menu item 1")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 2")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 3")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 4")
            }
        }
        .frame(width: space(38))
        .preferredColorScheme(.light)
        
        PopoverMenu {
            PopoverMenuItem(action: {}) {
                Text("Menu item 1")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 2")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 3")
            }
            PopoverMenuItem(action: {}) {
                Text("Menu item 4")
            }
        }
        .frame(width: space(38))
        .preferredColorScheme(.dark)
    }
}

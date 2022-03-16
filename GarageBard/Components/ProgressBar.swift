//
//  ProgressBar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import SwiftUI

struct OnSeek: ViewModifier {
    let seekAction: (_ percentage: Double) -> Void
    let seekEndAction: ((_ percentage: Double) -> Void)?

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geometry in
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: geometry.size.height + space(1))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                seekAction(min(max(value.location.x / geometry.size.width, 0), 1))
                            }
                            .onEnded { value in
                                if let action = seekEndAction {
                                    action(min(max(value.location.x / geometry.size.width, 0), 1))
                                }
                            }
                    )
            }
        }
    }
}

extension View {
    func onSeek(
        _ seekAction: @escaping (_ percentage: Double) -> Void
    ) -> some View {
        modifier(OnSeek(seekAction: seekAction, seekEndAction: nil))
    }

    func onSeek(
        seekAction: @escaping (_ percentage: Double) -> Void,
        seekEndAction: @escaping (_ percentage: Double) -> Void
    ) -> some View {
        modifier(OnSeek(seekAction: seekAction, seekEndAction: seekEndAction))
    }
}

struct ProgressBar: View {
    var value: Double

    var body: some View {
        Rectangle()
            .foregroundColor(Color("grey500"))
            .overlay {
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                        .foregroundColor(Color("grey400"))
                        .animation(.linear, value: value)
                }
            }
            .cornerRadius(45.0)
    }
}

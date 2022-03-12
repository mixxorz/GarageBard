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
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            seekAction(min(max(value.location.x / geometry.size.width, 0), 1))
                        }
                )
        }
    }
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .foregroundColor(Color("grey500"))
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color("grey400"))
                    .animation(.linear, value: value)
            }
            .cornerRadius(45.0)
        }
    }
    
    func onSeek(_ action: @escaping (_ percentage: Double) -> Void) -> some View {
        modifier(OnSeek(seekAction: action))
    }
}

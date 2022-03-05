//
//  ProgressBar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.white))
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(.blue))
                    .animation(.linear, value: value)
            }
            .cornerRadius(45.0)
        }
    }
}

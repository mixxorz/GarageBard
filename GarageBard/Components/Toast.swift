//
//  Toast.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import SwiftUI

struct Toast<Content: View>: View {
    var content: () -> Content
    var image: Image?
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    init(image: Image?, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.image = image
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: space(2), content: content)
            Spacer()
            if image != nil {
                image
                    .font(.system(size: 20))
                    .frame(width: space(8))
            }
        }
        .foregroundColor(Color.white)
        .padding(.vertical, space(2))
        .padding(.horizontal, space(3))
        .background(
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color("grey600"))
        )
        .frame(maxWidth: .infinity)
    }
}

struct Toast_Previews: PreviewProvider {
    static var previews: some View {
        Toast {
            Text("Five evening art drop camera can affect.")
        }
        .frame(width: space(100))
        
        Toast(image: Image(systemName: "music.note")) {
            Text("Fast part service city several. South say send less free even mind.")
            Text("Hotel dark too early.")
        }
        .frame(width: space(100))
    }
}

//
//  Notifications.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import SwiftUI

struct Notifications<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Toast {
                Text("Hello World")
            }
        }
        .padding(space(4))
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications<FakePlayerViewModel>()
            .frame(width: space(100))
            .background(Color("grey700"))
    }
}

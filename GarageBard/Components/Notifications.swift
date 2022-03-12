//
//  Notifications.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/12/22.
//

import SwiftUI

struct Notifications<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.controlActiveState) var controlActiveState
    
    var body: some View {
        VStack {
            Spacer()
            
            if !vm.hasAccessibilityPermissions {
                Toast(image: Image(systemName: "gear")) {
                    Text("GarageBard needs Accessibility access in order to send keystrokes to Final Fantasy XIV.")
                    Text("Tap to open macOS Accessibility preferences.")
                }
                .onTapGesture {
                    vm.checkAccessibilityPermissions(prompt: true)
                }
            }
        }
        .padding(space(4))
        .onChange(of: controlActiveState) { state in
            if state == .key || state == .active {
                vm.checkAccessibilityPermissions(prompt: false)
            }
        }
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications<FakePlayerViewModel>()
            .frame(width: space(100))
            .background(Color("grey700"))
    }
}

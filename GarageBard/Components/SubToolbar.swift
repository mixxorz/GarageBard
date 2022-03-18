//
//  SubToolbar.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/18/22.
//

import SwiftUI

struct SubToolbar<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel

    var body: some View {
        HStack {
            if let track = vm.track {
                TransposeField<ViewModel>(track: track)
            } else {
                InputField(name: "Tranpose", value: "-", onSetValue: { _ in })
            }

            Spacer()
        }
    }
}

struct SubToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SubToolbar<FakePlayerViewModel>()
            .environmentObject(FakePlayerViewModel())
            .frame(width: space(100))
            .padding(space(4))
            .background(Color("grey600"))
    }
}

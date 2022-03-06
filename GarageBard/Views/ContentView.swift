//
//  ContentView.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/4/22.
//

import Combine
import SwiftUI

func space(_ value: Int) -> CGFloat {
    return CGFloat(value * 4)
}

struct ContentView<Model: PlayerViewModelProtocol>: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        ZStack {
            Color("grey600")
            VStack {
                PlayerBar<Model>()
                SongLibrary<Model>()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: space(100), height: space(150))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView<FakePlayerViewModel>()
                .preferredColorScheme(.dark)
                .environmentObject(FakePlayerViewModel(song: nil, track: nil))
        }
    }
}

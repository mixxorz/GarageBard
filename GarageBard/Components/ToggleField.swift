//
//  ToggleField.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/19/22.
//

import SwiftUI

struct ToggleField: View {
    var name: String

    @FocusState var isFocused: Bool
    @Binding var value: Bool

    var onText: String = "ON"
    var offText: String = "OFF"

    var body: some View {
        VStack(alignment: .leading, spacing: space(1)) {
            Text(name)
                .font(.system(size: 10.0))
                .frame(maxWidth: space(20), alignment: .leading)
            ZStack {
                Rectangle()
                    .foregroundColor(Color("grey700"))
                    .frame(width: space(20), height: space(5))
                    .border(isFocused ? Color.accentColor : Color("grey500"), width: 1)
                    .onTapGesture {
                        value.toggle()
                    }

                Rectangle()
                    .foregroundColor(value ? Color.accentColor : Color.clear)
                    .frame(width: space(19), height: space(4))
                    .allowsHitTesting(false)

                Text(value ? onText : offText)
                    .frame(maxWidth: space(19))
                    .font(.system(size: 10.0))
                    .foregroundColor(value ? Color.white : Color("grey400"))
                    .allowsHitTesting(false)
            }
            .focusable()
            .focused($isFocused)
            .animation(nil, value: UUID())
        }
    }
}

struct ArpeggiateChordsField<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var track: Track

    var body: some View {
        ToggleField(name: "Arpeggiate", value: $track.arpeggiateChords)
            .onChange(of: track.arpeggiateChords) { _ in
                vm.reloadTrack()
            }
            .help("""
            Ensures that a chord's notes are played in ascending order.

            Notes played concurrently are played in ascending order (e.g. If G, C, and E are played at the same time, C is played first, then E, then G).
            """)
    }
}

struct AutoTransposeNotesField<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var track: Track

    var body: some View {
        ToggleField(name: "Octave remap", value: $track.autoTransposeNotes)
            .onChange(of: track.autoTransposeNotes) { _ in
                vm.reloadTrack()
            }
            .help("""
            Adjusts all notes to fit within the game's playable range (C2-C5).

            Notes outside the range are transposed N octaves up or down until they're within the range (e.g. D1->D2, A#7->A#4).
            """)
    }
}

struct ToggleField_Previews: PreviewProvider {
    static var previews: some View {
        ToggleField(name: "Octave remap", value: .constant(true), onText: "AUTO", offText: "SKIP")
            .foregroundColor(Color("grey400"))
            .padding(space(2))
            .background(Color("grey600"))

        ToggleField(name: "Auto-transpose", value: .constant(false))
            .foregroundColor(Color("grey400"))
            .padding(space(2))
            .background(Color("grey600"))

        ToggleField(name: "Arpeggiate", value: .constant(true))
            .foregroundColor(Color("grey400"))
            .padding(space(2))
            .background(Color("grey600"))
    }
}

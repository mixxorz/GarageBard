//
//  InputField.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/18/22.
//

import SwiftUI

struct InputField: View {
    var name: String
    var value: String
    var onSetValue: (_ value: String) -> Void

    @FocusState var isFocused: Bool
    @State var bufferValue: String = ""

    init(
        name: String,
        value: String,
        onSetValue: @escaping (String) -> Void
    ) {
        self.name = name
        self.value = value
        self.onSetValue = onSetValue
    }

    private func setValue() {
        if bufferValue != "" {
            onSetValue(bufferValue)
        }
        bufferValue = ""
        isFocused = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: space(1)) {
            Text(name)
                .font(.system(size: 12.0))
            ZStack {
                Rectangle()
                    .foregroundColor(Color("grey700"))
                    .frame(width: space(20), height: space(5))
                    .border(isFocused ? Color.accentColor : Color("grey500"), width: 1)
                    .onTapGesture {
                        isFocused = true
                    }

                TextField("", text: $bufferValue)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10.0))
                    .foregroundColor(Color("grey400"))
                    .opacity(bufferValue != "" ? 1 : 0)
                    .frame(width: space(20), height: space(5))
                    .onSubmit(setValue)
                    .focused($isFocused)
                    .onChange(of: isFocused, perform: { focused in
                        if !focused {
                            setValue()
                        }
                    })

                if bufferValue == "" {
                    Text(value)
                        .font(.system(size: 10.0))
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

struct TransposeField<ViewModel: PlayerViewModelProtocol>: View {
    @EnvironmentObject var vm: ViewModel
    @ObservedObject var track: Track

    var body: some View {
        InputField(name: "Transpose", value: track.getTranposedDisplay(), onSetValue: { value in
            vm.setTransposeAmount(fromString: value)
        })
    }
}

struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        InputField(name: "Tempo", value: "120-160 BPM") { _ in }
            .padding(space(4))
            .background(Color("grey600"))
    }
}

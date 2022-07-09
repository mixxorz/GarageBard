//
//  MIDIController.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 7/9/22.
//

import AudioKit
import CoreMIDI
import Foundation

/**
    Listens for inputs from available midi controllers
 */
class MIDIController: MIDIListener {
    private var sampler = ToneSampler()
    private var keyboard = KeyboardController()
    private var midi = MIDI.sharedInstance

    var playMode: PlayMode = .perform {
        didSet {
            if playMode == .perform {
                sampler.stop()
            } else if playMode == .listen {
                sampler.start()
            }
        }
    }

    @Published private(set) var midiDeviceNames: [String] = []

    init() {
        midi.openInput()
        midi.addListener(self)
    }

    deinit {
        sampler.stop()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        if playMode == .perform {
            if let keyCode = keyboard.getKeyCode(note: noteNumber) {
                keyboard.keyDown(keyCode)
            }
        } else {
            sampler.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity _: MIDIVelocity, channel: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        if playMode == .perform {
            if let keyCode = keyboard.getKeyCode(note: noteNumber) {
                keyboard.keyUp(keyCode)
            }
        } else {
            sampler.stop(noteNumber: noteNumber, channel: channel)
        }
    }

    func receivedMIDIController(_: MIDIByte, value _: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIAftertouch(noteNumber _: MIDINoteNumber, pressure _: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIAftertouch(_: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIPitchWheel(_: MIDIWord, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIProgramChange(_: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDISystemCommand(_: [MIDIByte], portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDISetupChange() {
        midiDeviceNames = midi.inputNames
    }

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {}

    func receivedMIDINotification(notification _: MIDINotification) {}
}

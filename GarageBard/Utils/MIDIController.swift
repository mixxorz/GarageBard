//
//  MIDIController.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 7/9/22.
//

import AudioKit
import CoreMIDI
import Foundation

class MIDIController: MIDIListener {
    private var sampler = ToneSampler()

    init() {
        let midi = MIDI.sharedInstance
        midi.openInput()
        midi.addListener(self)
        sampler.start()
    }

    deinit {
        sampler.stop()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        sampler.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity _: MIDIVelocity, channel: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        sampler.stop(noteNumber: noteNumber, channel: channel)
    }

    func receivedMIDIController(_: MIDIByte, value _: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIAftertouch(noteNumber _: MIDINoteNumber, pressure _: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIAftertouch(_: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIPitchWheel(_: MIDIWord, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDIProgramChange(_: MIDIByte, channel _: MIDIChannel, portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDISystemCommand(_: [MIDIByte], portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {}

    func receivedMIDISetupChange() {}

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {}

    func receivedMIDINotification(notification _: MIDINotification) {}
}

//
//  BardController.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/6/22.
//

import AudioKit
import Foundation

struct Note {
    let keyCode: CGKeyCode
    let desiredState: Bool
}

/**
    Queues and executes notes to be played
 */
class BardController {
    private var keyBuffer: CGKeyCode?
    private let queue = DispatchQueue(label: "bardcontroller.queue", qos: .userInteractive)
    private var noteBuffer: [Note] = []

    private var running = false

    private var tickRateMs: UInt32
    private var keyboard: KeyboardController

    init(tickRateMs: UInt32 = 25, keyboard: KeyboardController = KeyboardController()) {
        self.tickRateMs = tickRateMs
        self.keyboard = keyboard
    }

    func noteOn(_ note: MIDINoteNumber) {
        if let keyCode = keyboard.getKeyCode(note: note) {
            noteBuffer.append(Note(keyCode: keyCode, desiredState: true))
        }
    }

    func noteOff(_ note: MIDINoteNumber) {
        if let keyCode = keyboard.getKeyCode(note: note) {
            noteBuffer.append(Note(keyCode: keyCode, desiredState: false))
        }
    }

    func allNotesOff() {
        for (_, key) in keyboard.noteKeyMap {
            keyboard.keyUp(CGKeyCode(key))
        }
    }

    func start() {
        let tickRate = tickRateMs * 1000

        if !running {
            running = true

            // Clear buffer when starting
            noteBuffer = []

            queue.async {
                while self.running {
                    // Sleeping here effectively sets a limit for how fast two consecutive key-presses can happen
                    // We want to set this limit so that notes in quick succession remain distinct
                    usleep(tickRate)
                    if let note = self.noteBuffer.first {
                        self.noteBuffer.removeFirst()

                        if note.desiredState {
                            if let prevKeyCode = self.keyBuffer {
                                self.keyboard.keyUp(prevKeyCode)
                                usleep(tickRate)
                            }
                            self.keyboard.keyDown(note.keyCode)
                            self.keyBuffer = note.keyCode
                        } else {
                            self.keyboard.keyUp(note.keyCode)
                            self.keyBuffer = nil
                        }
                    }
                }

                // Lift all keys when stopping
                self.allNotesOff()
            }
        }
    }

    func stop() {
        running = false
    }
}

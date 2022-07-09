//
//  KeyboardController.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 7/9/22.
//

import AudioKit
import Carbon.HIToolbox
import Foundation

/**
    Sends keystrokes based on MIDI notes to the appropriate process
 */
class KeyboardController {
    private var hasAccessibilityPermissions = false
    private let sourceRef = CGEventSource(stateID: .combinedSessionState)
    let noteKeyMap = [
        // C
        84: kVK_ANSI_8,
        72: kVK_ANSI_1,
        60: kVK_ANSI_9,
        48: kVK_ANSI_Y,
        // C#
        73: kVK_ANSI_D,
        61: kVK_ANSI_K,
        49: kVK_ANSI_V,
        // D
        74: kVK_ANSI_2,
        62: kVK_ANSI_0,
        50: kVK_ANSI_U,
        // Eb
        75: kVK_ANSI_F,
        63: kVK_ANSI_L,
        51: kVK_ANSI_B,
        // E
        76: kVK_ANSI_3,
        64: kVK_ANSI_Q,
        52: kVK_ANSI_I,
        // F
        77: kVK_ANSI_4,
        65: kVK_ANSI_W,
        53: kVK_ANSI_O,
        // F#
        78: kVK_ANSI_G,
        66: kVK_ANSI_Z,
        54: kVK_ANSI_N,
        // G
        79: kVK_ANSI_5,
        67: kVK_ANSI_E,
        55: kVK_ANSI_P,
        // G#
        80: kVK_ANSI_H,
        68: kVK_ANSI_X,
        56: kVK_ANSI_M,
        // A
        81: kVK_ANSI_6,
        69: kVK_ANSI_R,
        57: kVK_ANSI_A,
        // Bb
        82: kVK_ANSI_J,
        70: kVK_ANSI_C,
        58: kVK_ANSI_Comma,
        // B
        83: kVK_ANSI_7,
        71: kVK_ANSI_T,
        59: kVK_ANSI_S,
    ]

    init() {
        hasAccessibilityPermissions = AXIsProcessTrusted()

        if sourceRef == nil {
            NSLog("KeyboardController: No event source")
        }

        if !hasAccessibilityPermissions {
            NSLog("KeyboardController: Do not have accessbility permissions")
        }
    }

    func getKeyCode(note: MIDINoteNumber) -> CGKeyCode? {
        let keyNumber = noteKeyMap[Int(note)] ?? -1

        if keyNumber == -1 {
            NSLog("KeyboardController: Note '\(note)' is out of bounds")
            return nil
        }

        return CGKeyCode(keyNumber)
    }

    func keyDown(_ keyCode: CGKeyCode) {
        let keyDownEvent = CGEvent(
            keyboardEventSource: sourceRef,
            virtualKey: keyCode,
            keyDown: true
        )

        if let pid = ProcessManager.instance.getXIVProcessId() {
            keyDownEvent?.postToPid(pid)
        } else {
            keyDownEvent?.post(tap: .cghidEventTap)
        }
    }

    func keyUp(_ keyCode: CGKeyCode) {
        let keyUpEvent = CGEvent(
            keyboardEventSource: sourceRef,
            virtualKey: keyCode,
            keyDown: false
        )

        if let pid = ProcessManager.instance.getXIVProcessId() {
            keyUpEvent?.postToPid(pid)
        } else {
            keyUpEvent?.post(tap: .cghidEventTap)
        }
    }
}

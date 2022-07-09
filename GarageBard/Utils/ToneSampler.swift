//
//  ToneSampler.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 7/9/22.
//

import AudioKit
import Foundation

/**
    Plays tones
 */
class ToneSampler: MIDISampler {
    private let engine = AudioEngine()

    deinit {
        engine.stop()
    }

    func start() {
        engine.output = self
        try? engine.start()
    }

    func stop() {
        engine.stop()
    }
}

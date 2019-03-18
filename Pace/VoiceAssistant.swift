//
//  VoiceAssistant.swift
//  Pace
//
//  Created by Ang Wei Neng on 18/3/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import AVFoundation

/// Voice assistant to convert text to speech.
class VoiceAssistant {
    static let voice = AVSpeechSynthesisVoice(language: "en-US")
    static let synth = AVSpeechSynthesizer()

    static func say(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice

        synth.speak(utterance)
    }
}

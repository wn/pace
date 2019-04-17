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

    /// timeDiff is pacer time - follower time
    static func reportPacing(using stats: PacingStats?) {
        var sentence: String
        guard let stats = stats else {
            sentence = "You are not on the original route"
            say(sentence)
            return
        }
        let time = Int(stats.timeDifference)
        let pacerName = stats.pacer.name
        if time > 0 {
            sentence = "You are \(time) seconds ahead of \(pacerName)"
        } else if time < 0 {
            sentence = "You are \(-time) seconds behind \(pacerName)"
        } else {
            sentence = "You are just as fast as \(pacerName)"
        }
        say(sentence)
    }
}

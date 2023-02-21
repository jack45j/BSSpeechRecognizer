//
//  BSSpeechRecognizerConfigurable.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/21.
//

import Foundation

public protocol BSSpeechRecognizerConfigurable {
    var locale: Locale { get set }
    
    /// This is NOT a time based duration
    /// This value is more like a counter based on AVAudioNode's tap
    var maxRecordDuration: Double { get set }
    
    var waveViewVisibleAnimateDuration: TimeInterval { get set }
}

public struct BSSpeechRecognizerConfiguration: BSSpeechRecognizerConfigurable {
    public var locale: Locale
    public var maxRecordDuration: Double
    public var waveViewVisibleAnimateDuration: TimeInterval
    
    public init(locale: Locale = .init(identifier: "zh-TW"),
                maxRecordDuration: Double = 300,
                waveViewVisibleAnimateDuration: TimeInterval = 0.5) {
        self.locale = locale
        self.maxRecordDuration = maxRecordDuration
        self.waveViewVisibleAnimateDuration = waveViewVisibleAnimateDuration
    }
}

//
//  BSSpeechRecognizer.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//

import Foundation
import Darwin
import AVFoundation
import Speech
import Accelerate

final public class BSSpeechRecognizer: NSObject {
    
    // AudioEngine
    private let audioEngine = AVAudioEngine()
    private var audioSession = AVAudioSession.sharedInstance()
    
    // Recognition
    private let authorizer: BSSpeechRecognizerAuthorizeManager = .init()
    private let presenter: BSSpeechRecognizeWaveViewPresenter
    private let config: any BSSpeechRecognizerConfigurable
    
    private var autoStopCounter: UInt = 0
    private var autoStopPower: Float = 0.25
    private var autoStopTimer: UInt
    
    private let LEVEL_LOWPASS_TRIG: Float32 = 0.2
    private var averagePower: Float = 0
    
    typealias ReccognitionResult = (SFSpeechRecognitionResult?, Error?) -> Void
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    public init(presenter: BSSpeechRecognizeWaveViewPresenter, config: any BSSpeechRecognizerConfigurable = BSSpeechRecognizerConfiguration()) {
        self.presenter = presenter
        self.config = config
        self.autoStopTimer = UInt(config.maxRecordDuration / 3)
    }
    
    public func start() {
        authorizer.validatePermissions { result in
            switch result {
            case .success:
                self.startRecognition()
            case let .failure(error):
                self.presenter.didFinishRecognition(with: error, animateDuration: self.config.waveViewVisibleAnimateDuration)
            }
        }
    }
    
    private func startRecognition() {
        OperationQueue.main.addOperation {
            self.presenter.didStartRecognition(animateDuration: self.config.waveViewVisibleAnimateDuration)
            do {
                try self.beginRecognition()
            } catch {
                self.presenter.didFinishRecognition(with: .unknown(error: error), animateDuration: self.config.waveViewVisibleAnimateDuration)
            }
        }
    }
    
    private func beginRecognition() throws {
        guard !audioEngine.isRunning else {
            interrupt(with: .cancelled(reason: .user))
            return
        }
        
        // Cancel the previous task if it's running.
        cancelPreviousTask()
        
        // Configure the audio session for the app.
        if configureAudioSession().isFailure {
            self.presenter.didFinishRecognition(with: .audioUnitFailed, animateDuration: config.waveViewVisibleAnimateDuration)
        }
        
        // Create and configuration RecognitionRequest.
        recognitionRequest = createRecognitionRequest()
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: recognitionTaskProcessor(result:error:))

        // Configure the microphone input.
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: recognitionInputNodeTapProcessor(buffer:when:))
        
        // Start AudioEngin
        if startAudioEngine().isFailure == false {
            autoStopCounter = 0
        }
    }
    
    private func cancelPreviousTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func cancelRecognitionRequest() {
        recognitionRequest?.endAudio()
        recognitionRequest = nil
    }
    
    /// cancel unfinish task and stop audioEngine
    /// - Hide WaveViewVisible
    private func finishRecognition() {
        cancelPreviousTask()
        stopAudioEngine()
        cancelRecognitionRequest()
        OperationQueue.main.addOperation {
            self.presenter.didFinishRecognition(animateDuration: self.config.waveViewVisibleAnimateDuration)
        }
    }
    
    /// Prepare and start AudioEngine
    private func startAudioEngine() -> Result<Void, BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError> {
        audioEngine.prepare()
        return Result {
            try audioEngine.start()
        }.mapError { _ in return BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError.audioUnitFailed }
    }
    
    private func stopAudioEngine() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func interrupt(with error: BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError) {
        cancelPreviousTask()
        cancelRecognitionRequest()
        stopAudioEngine()
        OperationQueue.main.addOperation {
            self.presenter.didFinishRecognition(with: error, animateDuration: self.config.waveViewVisibleAnimateDuration)
        }
    }
    
    // MARK: - Helpers
    private func configureAudioSession() -> Result<Void, BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError> {
        // Configure the audio session for the app.
        return Result {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }.mapError { _ in return BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError.audioUnitFailed }
    }
    
    private func createRecognitionRequest() -> SFSpeechAudioBufferRecognitionRequest {
        // Create and configure the speech recognition request.
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        return recognitionRequest
    }
    
    private func recognitionInputNodeTapProcessor(buffer: AVAudioPCMBuffer, when: AVAudioTime) {
        if autoStopCounter > autoStopTimer {
            finishRecognition()
        }
        recognitionRequest?.append(buffer)
        audioMetering(buffer: buffer)
    }
    
    private func recognitionTaskProcessor(result: SFSpeechRecognitionResult?, error: Error?) {
        var isFinal = false
        
        if let result = result, !result.bestTranscription.formattedString.isEmpty {
            isFinal = result.isFinal
            OperationQueue.main.addOperation {
                self.presenter.didRecognize(result.bestTranscription.formattedString, isFinal: result.isFinal)
                if isFinal {
                    self.finishRecognition()
                }
            }
        }
        
        if error != nil {
            interrupt(with: .unknown(error: error))
        }
    }
    
    private func audioMetering(buffer: AVAudioPCMBuffer) {
        buffer.frameLength = 1024
        let inNumberFrames: UInt = UInt(buffer.frameLength)
        if buffer.format.channelCount > 0 {
            guard let samples = (buffer.floatChannelData?[0]) else { return }
            var avgValue: Float32 = 0
            vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
            if avgValue != 0 {
                self.averagePower = (self.LEVEL_LOWPASS_TRIG * 15 * log10f(avgValue)) + ((1 - self.LEVEL_LOWPASS_TRIG) * self.averagePower)
            }
        }
        
        if averagePower < autoStopPower {
            autoStopCounter += 1
        } else {
            autoStopCounter = 0
        }
        
        OperationQueue.main.addOperation {
            self.presenter.updateWithLevel(self.normalizeSoundLevel(level: self.averagePower))
        }
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.001, CGFloat(level) + 50) / 2 // between 0.001 and 25
        return CGFloat(level * (1 / 25)) // scaled to max at 1 (our height of our bar)
    }
}

private extension Result {
    var isFailure: Bool {
        switch self {
        case .success:  return false
        case .failure:  return true
        }
    }
}

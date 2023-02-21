//
//  BSSpeechRecognizeWaveViewPresenter.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//

import Foundation

final public class BSSpeechRecognizeWaveViewPresenter {
    private var resourceView: BSSpeechDisplayView
    private let waveView: BSSpeechWaveView
    private let errorView: BSSpeechErrorView
    private let stateView: BSSpeechStateView
    
    public init(resourceView: BSSpeechDisplayView, waveView: BSSpeechWaveView, errorView: BSSpeechErrorView, stateView: BSSpeechStateView) {
        self.resourceView = resourceView
        self.waveView = waveView
        self.errorView = errorView
        self.stateView = stateView
    }
    
    func didRecognize(_ result: String, isFinal: Bool) {
        resourceView.display(.init(result: result, isFinal: isFinal))
    }
    
    func didStartRecognition(animateDuration: TimeInterval) {
        stateView.display(.init(isRecognizing: true))
        errorView.display(.noError)
        waveView.updateWithLevel(0.0)
        waveView.display(.init(duration: animateDuration, isShow: true))
    }
    
    func didFinishRecognition(with error: BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError? = nil, animateDuration: TimeInterval) {
        waveView.updateWithLevel(0.0)
        waveView.display(.init(duration: animateDuration, isShow: false))
        
        stateView.display(.init(isRecognizing: false))
        errorView.display(.init(message: error?.localizedDescription))
    }
    
    func updateWithLevel(_ level: CGFloat) {
        if level < 0 {
            waveView.updateWithLevel(0)
        } else if level > 1 {
            waveView.updateWithLevel(1)
        } else {
            waveView.updateWithLevel(level)
        }
    }
}

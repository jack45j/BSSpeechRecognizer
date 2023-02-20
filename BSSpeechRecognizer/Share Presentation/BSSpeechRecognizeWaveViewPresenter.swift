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
    private let loadingView: BSSpeechLoadingView
    
    public init(resourceView: BSSpeechDisplayView, waveView: BSSpeechWaveView, errorView: BSSpeechErrorView, loadingView: BSSpeechLoadingView) {
        self.resourceView = resourceView
        self.waveView = waveView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didFinishRecognition(with error: BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError) {
        didWaveViewVisible(to: false, duration: 0.5)
        errorView.display(.error(message: error.localizedDescription))
    }
    
    func didRecognize(_ result: String, isFinal: Bool) {
        resourceView.display(.init(result: result))
    }
    
    func didStartRecognition(_ duration: TimeInterval) {
        didWaveViewVisible(to: true, duration: duration)
    }
    
    func didWaveViewVisible(to show: Bool, duration: TimeInterval) {
        waveView.updateWithLevel(0.0)
        waveView.display(.init(duration: duration, isShow: show))
    }
    
    func updateWithLevel(_ level: CGFloat) {
        waveView.updateWithLevel(level)
    }
}

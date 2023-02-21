//
//  BSSpeechRecognizerTests.swift
//  BSSpeechRecognizerTests
//
//  Created by 林翌埕-20001107 on 2023/2/20.
//

import XCTest
@testable import BSSpeechRecognizer

final class BSSpeechRecognizerTests: XCTestCase {
    func test_initRecognizer_noMessagesDelivered() {
        let (_, viewSpy, waveSpy) = makeSUT()
        
        XCTAssertEqual(viewSpy.messages, [])
        XCTAssertEqual(viewSpy.results, [])
        XCTAssertEqual(waveSpy.messages, [])
    }
    
    func test_didStartRecognition_deliverEmptyError_isRecognizingStateTrue_resetWaveLevel_showWaveView() {
        let (sut, viewSpy, waveSpy) = makeSUT()
        
        sut.didStartRecognition(animateDuration: 0.0)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(isRecognizing: true),
            .display(errorMessage: nil)
        ])
        
        XCTAssertEqual(waveSpy.messages, [
            .display(level: 0.0),
            .display(isShow: true, animateDuration: 0.0)
        ])
    }
    
    func test_didFinishRecognition_deliverEmptyError_isRecognizingStateFalse_resetWaveLevel_hideWaveView() {
        let (sut, viewSpy, waveSpy) = makeSUT()
        
        sut.didFinishRecognition(with: nil, animateDuration: 0)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(isRecognizing: false),
            .display(errorMessage: nil)
        ])
        
        XCTAssertEqual(waveSpy.messages, [
            .display(level: 0.0),
            .display(isShow: false, animateDuration: 0.0)
        ])
    }
    
    func test_didFinishRecognition_deliverAuthFailError_isRecognizingStateFalse_resetWaveLevel_hideWaveView() {
        let (sut, viewSpy, waveSpy) = makeSUT()
        let error = BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError.authorization(reason: .denied)
        sut.didFinishRecognition(with: error, animateDuration: 0)
        
        XCTAssertEqual(viewSpy.messages, [
            .display(isRecognizing: false),
            .display(errorMessage: error.localizedDescription)
        ])
        
        XCTAssertEqual(waveSpy.messages, [
            .display(level: 0.0),
            .display(isShow: false, animateDuration: 0.0)
        ])
    }
    
    func test_didStartRecognition_updateWaveLevelsInValidRange_showWaveViewWithDuration() {
        let (sut, _, waveSpy) = makeSUT()
        
        sut.didStartRecognition(animateDuration: 0.1)
        sut.updateWithLevel(0.3)
        sut.updateWithLevel(0.4)
        sut.updateWithLevel(0.5)
        sut.updateWithLevel(0.6)
        
        XCTAssertEqual(waveSpy.messages, [
            .display(level: 0.0),
            .display(isShow: true, animateDuration: 0.1),
            .display(level: 0.3),
            .display(level: 0.4),
            .display(level: 0.5),
            .display(level: 0.6),
        ])
    }
    
    func test_didStartRecognition_updateWaveLevelsOutOfValidRange_showWaveViewWithDurationAndRestrictLevels() {
        let (sut, _, waveSpy) = makeSUT()
        
        sut.didStartRecognition(animateDuration: 0.1)
        sut.updateWithLevel(-0.5)
        sut.updateWithLevel(-3000)
        sut.updateWithLevel(0.5)
        sut.updateWithLevel(1.5)
        sut.updateWithLevel(200)
        
        XCTAssertEqual(waveSpy.messages, [
            .display(level: 0.0),
            .display(isShow: true, animateDuration: 0.1),
            .display(level: 0),
            .display(level: 0),
            .display(level: 0.5),
            .display(level: 1),
            .display(level: 1),
        ])
    }
    
    func test_didStartRecognition_deliverRecognizeResults() {
        let (sut, viewSpy, _) = makeSUT()
        
        sut.didStartRecognition(animateDuration: 0)
        sut.didRecognize("SomeResult", isFinal: false)
        sut.didRecognize("SomeResult1", isFinal: false)
        sut.didRecognize("SomeResult2", isFinal: false)
        sut.didRecognize("SomeResult3", isFinal: true)
        
        XCTAssertEqual(viewSpy.results, [
            .display(result: "SomeResult", isFinal: false),
            .display(result: "SomeResult1", isFinal: false),
            .display(result: "SomeResult2", isFinal: false),
            .display(result: "SomeResult3", isFinal: true),
        ])
    }
    
    func makeSUT() -> (sut: BSSpeechRecognizeWaveViewPresenter, viewSpy: ViewSpy, waveViewSpy: WaveViewSpy) {
        let viewSpy = ViewSpy()
        let waveViewSpy = WaveViewSpy()
        let presenter = BSSpeechRecognizeWaveViewPresenter(resourceView: viewSpy,
                                                           waveView: waveViewSpy,
                                                           errorView: viewSpy,
                                                           stateView: viewSpy)
        return (presenter, viewSpy, waveViewSpy)
    }
    
    class WaveViewSpy: BSSpeechWaveView {
        enum Message: Hashable {
            case display(level: CGFloat)
            case display(isShow: Bool, animateDuration: TimeInterval)
        }
        
        private(set) var messages = Set<Message>()
        
        func updateWithLevel(_ level: CGFloat) {
            messages.insert(.display(level: level))
        }
        
        func display(_ viewModel: BSSpeechWaveViewModel) {
            messages.insert(.display(isShow: viewModel.isShow, animateDuration: viewModel.duration))
        }
    }
    
    class ViewSpy: BSSpeechDisplayView, BSSpeechErrorView, BSSpeechStateView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isRecognizing: Bool)
        }
        
        enum Results: Hashable {
            case display(result: String, isFinal: Bool)
        }
        
        private(set) var messages = Set<Message>()
        private(set) var results = [Results]()
        
        func display(_ viewModel: BSSpeechDisplayViewModel) {
            results.append(.display(result: viewModel.result, isFinal: viewModel.isFinal))
        }
        
        func display(_ viewModel: BSSpeechErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: BSSpeechStateViewModel) {
            messages.insert(.display(isRecognizing: viewModel.isRecognizing))
        }
    }
}

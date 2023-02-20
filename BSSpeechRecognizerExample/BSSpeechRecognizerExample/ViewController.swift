//
//  ViewController.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//

import UIKit
import BSSpeechRecognizer

class ViewController: UIViewController, BSSpeechErrorView, BSSpeechLoadingView, BSSpeechDisplayView {
    
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func didTouchStartRecognition(_ sender: Any) {
        recognizer.start()
    }
    
    @IBOutlet weak var waveView: BSWaveVisualizeView!
    private lazy var recognizer = BSSpeechRecognizer(presenter:
            .init(resourceView: self,
                  waveView: waveView,
                  errorView: self,
                  loadingView: self))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func display(_ viewModel: BSSpeechLoadingViewModel) {
        
    }
    
    func display(_ viewModel: BSSpeechErrorViewModel) {
        
    }
    
    func display(_ viewModel: BSSpeechDisplayViewModel) {
        resultLabel.text = viewModel.result
    }
}

extension BSSpeechRecognizerAuthorizeManager.BSSpeechRecognizerError {
    var localizedDescription: String {
        switch self {
        case .authorization(let reason):
            switch reason {
            case .denied:
                return "語音辨識需要您的權限"
            case .restricted:
                return "語音辨識需要您的權限"
            case .usageDescription(let missing):
                return "語音辨識需要您的權限 \(missing)"
            }
        case .cancelled(let reason):
            switch reason {
            case .user:
                return ""
            case .notFound:
                return "無法偵測到您的語音"
            }
        case .recording:
            return "正在錄音"
        case .invalid(let locale):
            return "無效的語言設定 \(locale.identifier)"
        case .audioUnitFailed:
            return "audioUnitFailed"
        case .unknown(let error):
            return "發生未知錯誤: \(error?.localizedDescription ?? "Unknown")"
        }
    }
}

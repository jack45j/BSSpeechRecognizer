//
//  BSSpeechDisplayView.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//

import Foundation

public protocol BSSpeechWaveView {
    func updateWithLevel(_ level: CGFloat)
    func display(_ viewModel: BSSpeechWaveViewModel)
}

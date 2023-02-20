//
//  BSSpeechErrorViewModel.swift
//  BSSpeechRecognizer
//
//  Created by 林翌埕-20001107 on 2023/2/17.
//

import Foundation

public struct BSSpeechErrorViewModel {
    public let message: String?
    
    static var noError: BSSpeechErrorViewModel {
        return BSSpeechErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> BSSpeechErrorViewModel {
        return BSSpeechErrorViewModel(message: message)
    }
}

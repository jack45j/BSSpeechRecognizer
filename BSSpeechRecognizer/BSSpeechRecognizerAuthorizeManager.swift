//
//  BSSpeechRecognizerAuthorizeManager.swift
//  BSSpeechRecognizer
//
//  Created by Yi-Cheng Lin on 2023/2/17.
//

import Foundation
import Speech

final public class BSSpeechRecognizerAuthorizeManager {
    public typealias ResultHandlerClouse = (Result<Void, BSSpeechRecognizerError>) -> Void
    public typealias UsageDescriptionKey = String
    
    public enum BSSpeechRecognizerError: Error {
        public enum AuthorizationReason {
            case denied
            case restricted
            case usageDescription(missing: BSSpeechRecognizerAuthorizeManager.UsageDescriptionKey)
        }
        public enum CancellationReason {
            case user, notFound
        }
        case authorization(reason: AuthorizationReason)
        case cancelled(reason: CancellationReason)
        case recording
        case invalid(locale: Locale)
        case audioUnitFailed
        case unknown(error: Error?)
    }
    
    private let microphoneUsageDescriptionKey: UsageDescriptionKey = UsageDescriptionKey("NSMicrophoneUsageDescription")
    private let speechRecognitionUsageDescriptionKey: UsageDescriptionKey = UsageDescriptionKey("NSSpeechRecognitionUsageDescription")
    
    public func validatePermissions(_ handler: @escaping ResultHandlerClouse) {
        checkSpeechRecognizerAuthorization { result in
            switch result {
            case .success:
                self.checkMicrophoneAuthorization(handler)
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }
    
    private func checkSpeechRecognizerAuthorization(_ handler: @escaping ResultHandlerClouse) {
        guard Bundle.main.object(forInfoDictionaryKey: speechRecognitionUsageDescriptionKey) != nil else {
            handler(.failure(.authorization(reason: .usageDescription(missing: speechRecognitionUsageDescriptionKey))))
            return
        }
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return handler(.success(()))
        case .denied:
            return handler(.failure(.authorization(reason: .denied)))
        case .restricted:
            return handler(.failure(.authorization(reason: .restricted)))
        default:
            SFSpeechRecognizer.requestAuthorization { _ in
                self.checkSpeechRecognizerAuthorization(handler)
            }
        }
    }
    
    private func checkMicrophoneAuthorization(_ handler: @escaping ResultHandlerClouse) {
        guard Bundle.main.object(forInfoDictionaryKey: microphoneUsageDescriptionKey) != nil else {
            handler(.failure(.authorization(reason: .usageDescription(missing: microphoneUsageDescriptionKey))))
            return
        }
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return handler(.success(()))
        case .denied:
            return handler(.failure(.authorization(reason: .denied)))
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                self.checkMicrophoneAuthorization(handler)
            }
        @unknown default:
            return handler(.failure(.unknown(error: nil)))
        }
    }
}

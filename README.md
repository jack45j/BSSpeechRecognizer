# BSSpeechRecognizer
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![SPM compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

Integrate Speech framework and WaveformView(by jyunderwood)
## `Important!!!`  This project is currently pre-release. Some features or api interface may change frequently

## Installation
### Swift Package Manager

_Note: Instructions below are for using **SwiftPM** without the Xcode UI. It's the easiest to go to your Project Settings -> Swift Packages and add BSSpeechRecognizer from there._

To integrate using Apple's Swift package manager, without Xcode integration, add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/jack45j/BSSpeechRecognizer.git", .upToNextMajor(from: "0.1.0"))
```

## Requirements
- iOS 11
- add the “Privacy - Speech Recognition Usage Description” key (NSSpeechRecognitionUsageDescription) to your app’s Info.plist file
- add the “Privacy - Microphone Usage Description” key (NSMicrophoneUsageDescription) to your app’s Info.plist file

## Usage
- Initialize a BSSpeechRecognizer
  - resourceView should conform to BSSpeechDisplayView and will be use to handle the results of recognition
  - waveView should conform to BSSpeechWaveView and will be use to handle the changes of audio level (0~1)
    - There has a implemented waveView called BSWaveVisualizeView based on [WaveformView-iOS](https://github.com/jyunderwood/WaveformView-iOS) by jyunderwood
  - errorView should conform to BSSpeechErrorView and will be use to handle the Errors
  - stateView should conform to BSSpeechStateView and will be use to handle the changes of recognizer available state

```swift
let recognizer = BSSpeechRecognizer(
        presenter: BSSpeechRecognizeWaveViewPresenter(
            resourceView: self,
            waveView: waveView,
            errorView: self,
            stateView: self)
    )
```

```swift
@IBOutlet weak var waveView: BSWaveVisualizeView!
```

To Start recognize
```swift
recognizer.start()
```
System will ask Microphone and SpeechRecognition permissions when the first time start recoginzer.

## Implement protocols
### BSSpeechDisplayView
```swift
func display(_ viewModel: BSSpeechDisplayViewModel)

struct BSSpeechDisplayViewModel {
    var result: String
    var isFinal: Bool
}
```
### BSSpeechWaveView
```swift
func updateWithLevel(_ level: CGFloat)    
func display(_ viewModel: BSSpeechWaveViewModel)

struct BSSpeechWaveViewModel {
    var duration: TimeInterval
    var isShow: Bool
}
```

### BSSpeechErrorView
```swift
func display(_ viewModel: BSSpeechErrorViewModel)

struct BSSpeechErrorViewModel {
    let message: String?
}
```

### BSSpeechStateView
```swift
func display(_ viewModel: BSSpeechStateViewModel)

struct BSSpeechStateViewModel {
    let isRecognizing: Bool
}
```

## License

`BSSpeechRecognizer` is available under the MIT license. See the LICENSE file for more info.

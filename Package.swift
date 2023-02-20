// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "BSSpeechRecognizer",
    platforms: [.iOS(.v9), .tvOS(.v9)],
    products: [
        .library(name: "BSSpeechRecognizer", targets: ["BSSpeechRecognizer"])
    ],
    targets: [
        .target(name: "BSSpeechRecognizer", path: "BSSpeechRecognizer")
    ]
)

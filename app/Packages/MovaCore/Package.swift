// swift-tools-version:5.9
import PackageDescription

// Platform-independent logic for MOVA: shot plans, beat timing, match scoring,
// looks and export estimates. No UIKit/SwiftUI, so it builds and tests on macOS and Linux.
let package = Package(
    name: "MovaCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "MovaCore", targets: ["MovaCore"])],
    targets: [
        .target(name: "MovaCore"),
        .testTarget(name: "MovaCoreTests", dependencies: ["MovaCore"]),
    ]
)

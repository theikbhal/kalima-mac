// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "KalimaDaily",
    platforms: [.macOS(.v13)],
    targets: [ .executableTarget(name: "KalimaDaily", path: "Sources/KalimaDaily") ]
)

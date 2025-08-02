// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SpaceInvadersSwift",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "SpaceInvaders",
            path: "Sources/SpaceInvaders",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "penny",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
    ],
    targets: [
        // The API
        .target(name: "Mint", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Mint"]),
        .target(name: "Run", dependencies: ["App"]),

        // The API Connector
        .target(name: "PennyConnector", dependencies: ["Vapor", "Mint", "App"]),

        // Tests
        .testTarget(name: "AppTests", dependencies: ["App"]),
        .testTarget(name: "MintTests", dependencies: ["Mint"])
    ]
)


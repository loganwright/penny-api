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
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "GitHub", "Mint", "Slack"]),
        .target(name: "Mint", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "GitHub", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "Slack", dependencies: ["FluentPostgreSQL", "Vapor", "GitHub", "Mint"]),
        .target(name: "Run", dependencies: ["App"]),

        .testTarget(name: "AppTests", dependencies: ["App"]),
        .testTarget(name: "MintTests", dependencies: ["Mint"]),
        .testTarget(name: "GitHubTests", dependencies: ["GitHub"]),
        .testTarget(name: "SlackTests", dependencies: ["Slack"]),
    ]
)


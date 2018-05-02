// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "penny",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "../penny-core", .branch("master"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "GitHub", "Penny", "PennyCore"]),
        .target(name: "Penny", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "GitHub", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),

        .testTarget(name: "AppTests", dependencies: ["App"]),
        .testTarget(name: "PennyTests", dependencies: ["FluentPostgreSQL", "Vapor", "App"]),
        .testTarget(name: "GitHubTests", dependencies: ["GitHub"]),
    ]
)


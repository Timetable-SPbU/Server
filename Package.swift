// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Server",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git",
                 from: "1.0.0-rc"),

        .package(url: "../SPbUappModels", .branchItem("master"))
    ],
    targets: [
        .target(name: "ServerCore",
                dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "APIVersion1",
                dependencies: ["ServerCore", "SPbUappModelsV1"]),
        .target(name: "App",
                dependencies: ["APIVersion1"]),
        .target(name: "Run",
                dependencies: ["App"]),
        .testTarget(name: "AppTests",
                    dependencies: ["App"])
    ]
)


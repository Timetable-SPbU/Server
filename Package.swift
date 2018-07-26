// swift-tools-version:4.2
import PackageDescription

let package = Package(
  name: "Server",
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.7"),

    // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
    .package(url: "https://github.com/vapor/fluent-postgresql.git",
             from: "1.0.0"),

    .package(url: "../SPbUappModels", .branch("master")),
    .package(url: "https://github.com/Timetable-SPbU/TimetableSDK.git",
             .branch("master"))
  ],
  targets: [
    .target(name: "ServerCore",
            dependencies: ["FluentPostgreSQL",
                           "Vapor",
                           "TimetableSDK",
                           "SPbUappModelsV1"]),
    .target(name: "APIVersion1",
            dependencies: ["ServerCore", "SPbUappModelsV1"]),
    .target(name: "App",
            dependencies: ["APIVersion1"]),
    .target(name: "Run",
            dependencies: ["App"]),
    .testTarget(name: "AppTests",
                dependencies: ["App"])
  ],
  swiftLanguageVersions: [.v4_2]
)


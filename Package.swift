// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rate",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [.library(name: "Rate", targets: ["Rate"])],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-rational.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Rate",
            dependencies: [
                .product(name: "Rational", package: "swift-rational")
            ]
        ),
        .testTarget(
            name: "Rate Tests",
            dependencies: [
                .target(name: "Rate")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}

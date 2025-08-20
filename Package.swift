// swift-tools-version:6.1
import CompilerPluginSupport
import PackageDescription
import typealias Foundation.ProcessInfo

let package: Package = .init(
    name: "bijection",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Bijection", targets: ["Bijection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
    ],
    targets: [
        .macro(
            name: "BijectionMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Bijection",
            dependencies: ["BijectionMacro"]
        ),
        .testTarget(
            name: "BijectionTests",
            dependencies: ["Bijection"]
        ),
    ]
)

for target: Target in package.targets {
    let swift: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
    ]

    {
        $0 = ($0 ?? []) + swift
    } (&target.swiftSettings)
}

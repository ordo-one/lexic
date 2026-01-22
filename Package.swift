// swift-tools-version:6.2
import CompilerPluginSupport
import PackageDescription

let package: Package = .init(
    name: "bijection",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Bijection", targets: ["Bijection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(path: "https://github.com/ordo-one/lexic.git"),
    ],
    targets: [
        .macro(
            name: "BijectionMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "Lexic", package: "lexic"),
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
        .treatWarning("ExistentialAny", as: .error),
        .treatWarning("MutableGlobalVariable", as: .error),
    ]

    {
        $0 = ($0 ?? []) + swift
    } (&target.swiftSettings)
}

// swift-tools-version:6.2
import CompilerPluginSupport
import Foundation
import PackageDescription

let package: Package = .init(
    name: "bijection",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Bijection", targets: ["Bijection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        // .package(url: "https://github.com/ordo-one/lexic.git", from: "0.1.0"),
        .package(url: "https://github.com/ordo-one/dollup.git", from: "1.0.0"),
    ],
    targets: [
        .macro(
            name: "BijectionMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                // .product(name: "Lexic", package: "lexic"),
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
    {
        var settings: [SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))

        let warningsAsErrors: Bool
        #if os(macOS)
        warningsAsErrors = ProcessInfo.processInfo.environment[
            "BUILD_WARNINGS_AS_ERRORS"
        ] == "true"
        #else
        warningsAsErrors = true
        #endif

        if  warningsAsErrors {
            settings.append(.treatWarning("ExistentialAny", as: .error))
            settings.append(.treatWarning("MutableGlobalVariable", as: .error))
        }

        $0 = settings
    } (&target.swiftSettings)
}

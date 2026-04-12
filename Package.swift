// swift-tools-version:6.2
import CompilerPluginSupport
import Foundation
import PackageDescription

let package: Package = .init(
    name: "lexic",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Bijection", targets: ["Bijection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.0"),
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.2"),
    ],
    targets: [
        .macro(
            name: "Lexic",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Bijection",
            dependencies: ["Lexic"]
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
        settings.append(.enableUpcomingFeature("InternalImportsByDefault"))

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

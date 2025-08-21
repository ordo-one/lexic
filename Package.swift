// swift-tools-version:6.1
import CompilerPluginSupport
import PackageDescription

func makeSwiftSyntaxDependency() -> [Package.Dependency] {
    let xcFrameworksRepo: String = "https://github.com/ordo-one/swift-syntax-xcframeworks"
    let officialSyntaxRepo: String = "https://github.com/swiftlang/swift-syntax"

    let syntaxUrl: String
    #if os(iOS)
        syntaxUrl = xcFrameworksRepo
    #elseif os(Linux)
        syntaxUrl = officialSyntaxRepo
    #else
        syntaxUrl = useSwiftSyntaxXcf ? xcFrameworksRepo : officialSyntaxRepo
    #endif

    return [.package(url: syntaxUrl, from: "601.0.1")]
}

func makeSwiftSyntaxTargetDependencies() -> [Target.Dependency] {
    let xcFrameworkDependencies: [Target.Dependency] = [
        .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
    ]

    let standardSyntaxDependencies: [Target.Dependency] = [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
    ]

    #if os(iOS)
        return xcFrameworkDependencies
    #elseif os(Linux)
        return standardSyntaxDependencies
    #else
        if useSwiftSyntaxXcf {
            return xcFrameworkDependencies
        }
        return standardSyntaxDependencies
    #endif
}

let package: Package = .init(
    name: "bijection",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Bijection", targets: ["Bijection"]),
    ],
    dependencies: makeSwiftSyntaxDependency(),
    targets: [
        .macro(
            name: "BijectionMacro",
            dependencies: makeSwiftSyntaxTargetDependencies(),
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

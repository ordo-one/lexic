<div align="center">

🥨 &nbsp; **lexic** &nbsp; 🥨

generate roundtripping logic for `RawRepresentable`, `LosslessStringConvertible`, and more!

[documentation](https://swiftinit.org/docs/lexic) ·
[license](LICENSE)

</div>


## Requirements

`@Bijection` is a Swift macro that generates an initializer from a `switch`-`case` mapping of an enum’s cases to set of corresponding values. It is useful for generating roundtripping logic for things like binary encodings and string representations, in situations where relying on native raw value-backed enums is insufficient, experiences poor performance due to lack of inlining, or would interfere with other compiler features, such as [synthesized `Comparable`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0266-synthesized-comparable-for-enumerations.md).

The `@Bijection` library requires Swift 6.1 or later.

<!-- DO NOT EDIT BELOW! AUTOSYNC CONTENT [STATUS TABLE] -->
| Platform | Status |
| -------- | ------|
| 💬 Documentation | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Documentation/_all/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Documentation.yml) |
| 🐧 Linux | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/Linux/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/macOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (iOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/iOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (tvOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/tvOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (visionOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/visionOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (watchOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/watchOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
<!-- DO NOT EDIT ABOVE! AUTOSYNC CONTENT [STATUS TABLE] -->

[Check deployment minimums](https://swiftinit.org/docs/lexic#ss:platform-requirements)


## Examples

Generate a plain, unlabeled initializer:

```swift
enum Enum: CaseIterable, Equatable {
    case a, b, c

    @Bijection
    var value: Unicode.Scalar {
        switch self {
        case .a: "a"
        case .b: "b"
        case .c: "c"
        }
    }
}

/* --- EXPANDS TO --- */
extension Enum {
    init?(_ $value: borrowing Unicode.Scalar) {
        switch $value {
        case "a":
            self = .a
        case "b":
            self = .b
        case "c":
            self = .c
        default:
            return nil
        }
    }
}
```

Generate an initializer with a custom argument label:

```swift
extension Enum {
    @Bijection(label: "index")
    var index: Int {
        switch self {
        case .a: 1
        case .b: 2
        case .c: 3
        }
    }
}

/* --- EXPANDS TO --- */
extension Enum {
    init?(index $value: borrowing Int) {
        switch $value {
        case 1:
            self = .a
        case 2:
            self = .b
        case 3:
            self = .c
        default:
            return nil
        }
    }
}
```

Generate an initializer from a getter in a property with multiple accessors:

```swift
extension Enum: LosslessStringConvertible {
    @Bijection
    var description: String {
        get {
            switch self {
            case .a: "A"
            case .b: "B"
            case .c: "C"
            }
        }
        set(value) {
            if let value: Self = .init(value) {
                self = value
            }
        }
    }
}
/* --- EXPANDS TO --- */
extension Enum {
    init?(_ $value: borrowing String) {
        switch $value {
        case "A":
            self = .a
        case "B":
            self = .b
        case "C":
            self = .c
        default:
            return nil
        }
    }
}
```

The `@Bijection` macro will mirror the access control (and other modifiers, such as `nonisolated`) of the property it is applied to.
It will also copy the following attributes, if present:

1. `@available`
1. `@backDeployed`
1. `@inlinable`
1. `@inline`
1. `@usableFromInline`

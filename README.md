<div align="center">

🥨 &nbsp; **lexic** &nbsp; 🥨

generate roundtripping logic for `RawRepresentable`, `LosslessStringConvertible`, and more!

[documentation](https://swiftinit.org/docs/lexic) ·
[license](LICENSE)

</div>


## Requirements

The `lexic` package provides low-level Swift macros for working with enum mappings. It requires Swift 6.1 or later.

<!-- DO NOT EDIT BELOW! AUTOSYNC CONTENT [STATUS TABLE] -->
| Platform | Status |
| -------- | ------ |
| 💬 Documentation | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Documentation/_all/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Documentation.yml) |
| 🐧 Linux | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/Linux/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/macOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (iOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/iOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (tvOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/tvOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (visionOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/visionOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
| 🍏 Darwin (watchOS) | [![Status](https://raw.githubusercontent.com/ordo-one/lexic/refs/badges/ci/Tests/watchOS/status.svg)](https://github.com/ordo-one/lexic/actions/workflows/Tests.yml) |
<!-- DO NOT EDIT ABOVE! AUTOSYNC CONTENT [STATUS TABLE] -->

[Check deployment minimums](https://swiftinit.org/docs/lexic#ss:platform-requirements)


## Inverting mappings with @Bijection

`@Bijection` is a Swift macro that generates an initializer from a `switch`-`case` mapping of an enum’s cases to a set of corresponding values. It is useful for generating roundtripping logic for binary encodings and string representations, in situations where relying on native raw value-backed enums is insufficient, experiences poor performance due to lack of inlining, or would interfere with other compiler features, such as [synthesized `Comparable`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0266-synthesized-comparable-for-enumerations.md).

Generate a plain, unlabeled initializer:

```swift
enum Enum: CaseIterable, Equatable {
    case a, b, c

    @Bijection var value: Unicode.Scalar {
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
    @Bijection(label: "index") var index: Int {
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
    @Bijection var description: String {
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


## Discriminated unions

A **discriminated union** is an enumeration whose cases represent distinct, heterogeneous variants—such as states in a state machine, actions in an event bus, or AST nodes in a compiler. When variants carry payloads, standard Swift patterns can quickly become cumbersome: matching variants requires payload pattern matching even when you only care about the case tag, constructing default variants requires explicit parameters, and extracting shared properties across diverse payloads requires repetitive `switch` expressions.

The `lexic` package provides four complementary macros to model discriminated unions concisely.


### Discriminator extraction with @Discriminated

When an enumeration contains cases with associated values, you often need a parallel representation that strips away the payloads—a **discriminator**. Discriminators are useful for indexing, hashing, serialization, or table-driven lookups where payloads are irrelevant.

The `@Discriminated` macro synthesizes a peer enumeration suffixed with `Type` containing identical case names without payloads, along with a computed `type` property inside the host enum:

```swift
@Discriminated(backing: String.self) enum Action {
    case start
    case stop
    case reset(Int?)
}

/* --- EXPANDS TO --- */
enum ActionType: String {
    case start
    case stop
    case reset
}

// Synthesized inside Action:
var type: ActionType {
    switch self {
    case .start:
        .start
    case .stop:
        .stop
    case .reset:
        .reset
    }
}
```

You can provide an optional raw backing type using `backing:`. Because the synthesized peer name is deterministically suffixed with `Type`, `@Discriminated` can be attached directly to top-level enumerations declared at file scope.


### Nested discriminated unions with @Discriminant

When producing code for environments that require flat, single-token top-level types (such as TypeScript API bindings generated by Dollup), the discriminator enumeration often serves as the outer type, with the payload-bearing variants nested inside (such as `TooltipType.Union`).

The `@Discriminant` macro pairs with an inner `@Discriminated(by:)` annotation. You declare the outer discriminator enumeration and nest the variant enum inside it, pointing back to the outer type using `by:`:

```swift
@Discriminant public enum TooltipType {
    @Discriminated(by: TooltipType.self) public enum Union {
        case text(String)
        case icon(Int)
        case custom
    }
}

/* --- EXPANDS TO --- */
// Synthesized inside Union:
public var type: TooltipType {
    switch self {
    case .text:
        .text
    case .icon:
        .icon
    case .custom:
        .custom
    }
}

// Synthesized inside TooltipType:
case text
case icon
case custom
```

Call sites can obtain the discriminator tag from a variant value using the `.type` property:

```swift
let type: TooltipType = value.type // .text
```

The outer `@Discriminant` macro automatically detects the nested enum annotated with `@Discriminated(by:)`. Raw backing types (such as `enum TooltipType: String`) are fully supported by applying the raw type directly to the host enum declaration.


## Ambient constructors with @ambient

Swift requires call-site arguments when instantiating any case with an associated value, even if every associated value is optional or provides a default argument. This prevents developers from using fluent dot syntax like `.reset` or `.staging`.

The `@ambient` macro restores zero-argument member access by synthesizing static properties for any case whose parameters are completely optional or supply default arguments:

```swift
@ambient enum Task {
    case recurring(interval: Int = 60, tag: String? = nil)
    case quick
    case custom(deadline: Date)
}

/* --- EXPANDS TO --- */
// Synthesized inside Task:
static var recurring: Self {
    .recurring(interval: 60, tag: nil)
}
```

Parameters that define default arguments use those defaults in the synthesized constructor, while optional parameters without defaults receive `nil`. Cases without associated values (such as `.quick`) already support zero-argument dot syntax natively in Swift and are skipped. Any case containing non-optional parameters lacking default arguments—such as `.custom(deadline:)`—is also skipped.


## Polymorphic projection with @Projection

Enumeration variants often carry disparate payload types that nevertheless share common concepts, such as a name, an identifier, or an account reference. Querying such attributes typically requires writing boilerplate `switch` blocks across every case.

The `@Projection` macro synthesizes a computed property that unwraps single-parameter payloads and delegates to a named `static func`:

```swift
@Projection(through: "id") enum Target {
    case user(User)
    case session(Session?)
    case anonymous

    static func id(_ value: some Identifiable<String>) -> String {
        value.id
    }
}

/* --- EXPANDS TO --- */
// Synthesized inside Target:
var id: String? {
    switch self {
    case .user(let scope):
        Self.id(scope)
    case .session(let scope?):
        Self.id(scope)
    default:
        nil
    }
}
```

If a case payload is optional, `@Projection` unwraps it via optional pattern matching (`let scope?`) so the projection function receives a non-optional argument. By default, `@Projection` also flattens optional return types to prevent double optionals (`String??`).

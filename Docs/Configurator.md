In Swift, it is common to vend APIs that allow the user to pass some trailing configuration
closure, like this:

```swift
struct ThrowsNever {
    init(
        x: Int,
        f: (inout Self) -> () = { _ in }
    ) {
        f(&self)
    }

    static var example: Self { .init(x: 1) }
}
```

In this example, the closure was non-throwing, so it could provide a default argument, allowing
the user to elide it.

Things become much trickier when `throws` becomes involved. Although you *can* provide a
non-throwing default argument for the closure, it will always be upcast to a throwing closure,
which propogates through `rethrows`, forcing every call to be written with `try`, even with the
default empty closure.

```swift
struct ThrowsAny {
    init(
        x: Int,
        f: (inout Self) throws -> () = { _ throws(Never) in }
    ) rethrows {
        try f(&self)
    }

    static var example: Self { get throws { try .init(x: 1) } }
}
```

Typed throws does not help us here either, in fact, explicitly typing the closure as
`throws(Never)`, or leaving it uncolored will actively inhibit type checking.

```swift
struct ThrowsTyped {
    init<E>(
        x: Int,
        f: (inout Self) throws(E) -> () = { _ throws in }
    ) rethrows {
        try f(&self)
    }

    static var example: Self { get throws { try .init(x: 1) } }
}
```

The solution we propose is to have an attached peer macro (`@attached(peer, names: overloaded)`)
named `@Configurator`, which can be applied to any initializer declaration whose final argument
is a throwing closure returning `Void` (`()`).

```swift
@Configurator public init<E>(
    foo: AccountIdentifier,
    bar: [[Int]],
    body: (inout Self) throws(E) -> ()
) async throws(E) {
}

// --- generates ---

public init(
    foo: AccountIdentifier,
    bar: [[Int]],
) async {
    await self.init(
        foo: foo,
        bar: bar,
        body: { (inout Self) throws(Never) -> () in }
    )
}
```

Some edge cases to look out for:

-   `init`s with multiple generic parameters besides the closure’s error type
-   `init`s that use `rethrows`
-   `init`s that have other throwing closure arguments, and thus would still throw, even if an
    empty closure were passed to the final argument. In this situation, the macro is less
    useful, but should still degrade gracefully.


## Signature synthesis and parameter forwarding

The generated peer initializer copies all parameters preceding the final closure parameter,
preserving their external argument labels, internal parameter names, type annotations,
parameter attributes (such as `@escaping` or `@Sendable`), and default argument expressions.
In the delegating `self.init` call, parameters with wildcard (`_`) labels are passed unlabeled,
labeled parameters are passed using their external argument label, and `inout` parameters are
prefixed with `&`. For the final argument, the macro synthesizes an empty closure literal
annotated with `throws(Never)` whose parameter list matches the arity and types of the closure
parameter. Because Swift does not allow forwarding a variadic parameter directly to another
variadic parameter, the macro rejects initializers containing variadic parameters with a
diagnostic.

The peer declaration also preserves the access control modifier, failability (`init?` or
`init!`), and applicable attributes (such as `@inlinable` and `@available`, excluding
`@Configurator` itself) from the original initializer. The `@MainActor` attribute is mirrored
as well, since a nonisolated peer could not call a main actor-isolated initializer
synchronously; custom global actor attributes cannot be told apart from other attributes by
syntax alone and are not mirrored. Because delegating to `self.init` within a class requires a
convenience initializer, the macro inspects `context.lexicalContext` and inserts the
`convenience` modifier when the enclosing type is a `ClassDeclSyntax` (if not already
present). The `override` modifier is dropped from the peer: when the superclass uses `@Configurator`
too, the peer coincides with the convenience initializer synthesized there, and Swift forbids
`override` on an initializer that matches a convenience initializer of the superclass. A
superclass that independently declares the shorter initializer as a designated one cannot be
told apart by syntax, and is not supported.


## Generics and effects propagation

To handle generic error parameters without performing surgery on generic `where` clauses,
`Lexic` provides `TypeSyntax.contains(symbol:)` and
`GenericRequirementSyntax.contains(symbol:)`. When the trailing closure throws a typed error
`E` declared as a generic parameter on the initializer, the macro uses these helpers to check
whether `E` is referenced in any preceding parameter types, inherited generic constraints, or
`where` clause requirements. Since the empty closure substitutes `Never` for `E`, the macro
also requires that `E` itself is constrained to nothing but `Error`. If `E` appears only as the
thrown error type, the macro drops `E`
from the peer initializer’s generic parameter list (removing the generic parameter clause
entirely if `E` was the only generic parameter) while leaving any remaining generic parameters
and the `where` clause untouched. If `E` is constrained in the `where` clause or referenced by
another parameter, the macro refuses to strip `E` and emits a diagnostic.

If the original initializer is `async`, the generated peer initializer is also `async` and
delegates with `await self.init(...)`. When the original initializer throws `E` and `E` is
substituted with `Never` by the empty closure, the peer initializer omits `throws` entirely.
Likewise, if the original initializer uses `rethrows` and has no other throwing closure
parameters (an optional throwing closure counts, as Swift lets it drive `rethrows`), the peer
initializer omits `rethrows` and becomes non-throwing, since Swift does
not permit `rethrows` on declarations without throwing closure parameters. If the initializer
has earlier throwing closure parameters or uses unconditional untyped `throws`, the generated
peer retains the remaining `throws` or `rethrows` clause and delegates using `try self.init(...)`.


## Diagnostics

The macro should refuse to generate any peer declarations and emit a diagnostic in the
following situations:

-   The macro is attached to a declaration other than an initializer (`InitializerDeclSyntax`).
-   The initializer has no parameters, or its final parameter is not a closure type.
-   The final closure parameter has a non-`Void` return type.
-   The final parameter type is a non-throwing closure, in which case the diagnostic should
    instruct the user to provide a default argument (`= { _ in }`) instead.
-   The closure’s generic error parameter is referenced in another parameter, constrained in
    a `where` clause, or constrained to anything other than `Error`.
-   Any preceding parameter is variadic.
-   The initializer is a protocol requirement.

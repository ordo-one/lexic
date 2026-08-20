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

The solution we propose is to have a macro named `@Configurator`, which can be applied to any
initializer declaration whose final argument is a closure.

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

If the final parameter type is a non-throwing closure, the macro should refuse to generate any
peer declarations, and instead instruct the user to provide a default argument instead.

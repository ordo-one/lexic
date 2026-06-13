/// Asserts that a condition is true, terminating execution if it is not.
///
/// This assertion is only active in builds where the `ASSERT` compilation
/// condition is set (for example, builds configured with `-D ASSERT`).
///
/// Unlike the standard library's `assert`, this macro does not use `@autoclosure`
/// for its condition or message, which avoids common issues with tuple captures
/// and other complex expressions.
///
/// - Parameters:
///   - condition: The condition to test. This expression is only evaluated in
///     `ASSERT` builds.
///   - message: A string to print if `condition` is `false`. This expression
///     is only evaluated if `condition` is `false` in a `ASSERT` build.
@freestanding(expression) public macro assert(
    _ condition: Bool,
    _ message: String
) = #externalMacro(
    module: "AssertMacro",
    type: "AssertMacro"
)

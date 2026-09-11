/// Synthesizes zero-argument static properties on an enumeration for cases whose
/// associated values are optional or supply default arguments.
///
/// When an enumeration case declares associated values, Swift ordinarily requires
/// call-site arguments even when defaults or optionals exist. The `@ambient` macro
/// restores fluent zero-argument member syntax by generating static properties:
///
/// ```swift
/// @ambient enum Task {
///     case quick
///     case recurring(interval: Int = 60, tag: String? = nil)
///     case custom(deadline: Date)
/// }
/// ```
///
/// This synthesizes:
///
/// ```swift
/// extension Task {
///     static var quick: Self { .quick }
///     static var recurring: Self { .recurring(interval: 60, tag: nil) }
/// }
/// ```
///
/// Any case with non-optional associated values lacking default arguments—such
/// as `.custom(deadline:)` above—is left untouched.
///
/// > Note: Associated value types must use the sugared optional spelling `?`
/// rather than `Optional<T>`.
@attached(
    member,
    names: arbitrary
) public macro ambient() = #externalMacro(
    module: "LexicMacros",
    type: "AmbientMacro"
)

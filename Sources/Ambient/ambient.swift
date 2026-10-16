/// Synthesizes zero-argument static properties on an enumeration for cases whose
/// associated values are optional or supply default arguments.
///
/// When an enumeration case declares associated values, Swift ordinarily requires
/// call-site arguments even when defaults or optionals exist. The `@ambient` macro
/// restores fluent zero-argument member syntax by generating static properties
/// inside the enumeration:
///
/// ```swift
/// @ambient enum Task {
///     case recurring(interval: Int = 60, tag: String? = nil)
///     case quick
///     case custom(deadline: Date)
/// }
/// ```
///
/// This synthesizes the following member on `Task`:
///
/// ```swift
/// static var recurring: Self {
///     .recurring(interval: 60, tag: nil)
/// }
/// ```
///
/// Cases without associated values (such as `.quick`) already support zero-argument
/// dot syntax natively in Swift and are skipped. Cases with non-optional associated
/// values lacking default arguments (such as `.custom(deadline:)`) cannot be called
/// without arguments and are also skipped.
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

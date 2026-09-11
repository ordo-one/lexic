/// Synthesizes a computed property that projects single-parameter case payloads
/// into a common type through a static function.
///
/// When an enumeration defines disparate cases that share common metadata, extracting
/// that metadata often requires boilerplate `switch` blocks. The `@Projection` macro
/// matches single-parameter cases and applies the named static projection function
/// to their payloads:
///
/// ```swift
/// @Projection(through: "id") enum Target {
///     case user(User)
///     case session(Session?)
///     case anonymous
///
///     static func id(_ value: some Identifiable<String>) -> String {
///         value.id
///     }
/// }
/// ```
///
/// This synthesizes:
///
/// ```swift
/// extension Target {
///     var id: String? {
///         switch self {
///         case .user(let scope):     Self.id(scope)
///         case .session(let scope?): Self.id(scope)
///         default: nil
///         }
///     }
/// }
/// ```
///
/// If a case payload is optional, pattern matching unwraps it with `let scope?`
/// so the projection function receives a non-optional value. Cases with multiple
/// associated values or no associated values fall through to `nil`.
///
/// - Parameters:
///   - through: The name of the static projection function declared on the enum.
///     The synthesized property will use this same name.
///   - flatten: A Boolean value indicating whether to avoid double optionals
///     when the projection function itself returns an optional. Defaults to `true`.
@attached(
    member,
    names: arbitrary
) public macro Projection(
    through: String,
    flatten: Bool = true
) = #externalMacro(
    module: "LexicMacros",
    type: "ProjectionMacro"
)

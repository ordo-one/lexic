/// Synthesizes an initializer from a computed property whose getter maps enum cases
/// to a set of distinct values.
///
/// This macro generates the inverse mapping for properties that express a bijection
/// between an enumeration and a set of values, such as raw representations or
/// string encodings:
///
/// ```swift
/// enum Code {
///     case ok
///     case notFound
///
///     @Bijection var status: Int {
///         switch self {
///         case .ok: 200
///         case .notFound: 404
///         }
///     }
/// }
/// ```
///
/// This generates:
///
/// ```swift
/// extension Code {
///     init?(_ $value: borrowing Int) {
///         switch $value {
///         case 200: self = .ok
///         case 404: self = .notFound
///         default: return nil
///         }
///     }
/// }
/// ```
///
/// - Parameters:
///   - label: The argument label for the synthesized initializer. Defaults to `_`.
///   - where: An optional condition or discriminator applied to the synthesized mapping.
@attached(
    peer,
    names: named(init)
) public macro Bijection(label: String = "_", where: String? = nil) = #externalMacro(
    module: "LexicMacros",
    type: "BijectionMacro"
)

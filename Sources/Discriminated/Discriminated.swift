/// Synthesizes a payload-free peer enumeration — a *discriminator* — and a computed
/// `type` property returning the discriminator for the current case.
///
/// This macro is useful when an enumeration contains cases with associated values,
/// but you need a lightweight representation of the cases without their payloads
/// for hashing, serialization, or table-driven lookups. The generated peer enum
/// automatically conforms to ``CaseIterable`` and ``Sendable``.
///
/// ```swift
/// @Discriminated(backing: String.self) enum Action {
///     case start
///     case stop
///     case reset(Int?)
/// }
/// ```
///
/// This generates:
///
/// ```swift
/// enum ActionType: String, CaseIterable, Sendable {
///     case start
///     case stop
///     case reset
/// }
///
/// extension Action {
///     var type: ActionType {
///         switch self {
///         case .start: .start
///         case .stop: .stop
///         case .reset: .reset
///         }
///     }
/// }
/// ```
///
/// - Parameters:
///   - discriminant: The name of the synthesized peer enumeration. Defaults to the
///     host enum’s name suffixed with `Type`.
///   - backing: An optional raw-value type (such as `Int.self` or `String.self`)
///     for the synthesized peer enumeration.
@attached(
    peer,
    names: arbitrary
) @attached(
    member,
    names: named(type)
) public macro Discriminated(
    discriminant: String? = nil,
    backing: Any.Type? = nil
) = #externalMacro(
    module: "LexicMacros",
    type: "DiscriminatedMacro"
)

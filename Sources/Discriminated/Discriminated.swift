/// Synthesizes a payload-free peer enumeration — a *discriminator* — and a computed
/// `type` property returning the discriminator for the current case.
///
/// This macro is useful when an enumeration contains cases with associated values,
/// but you need a lightweight representation of the cases without their payloads
/// for hashing, serialization, or table-driven lookups.
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
/// enum ActionType: String {
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
/// Because the peer enumeration name is deterministically suffixed with `Type`,
/// `@Discriminated` can be attached to top-level enumerations declared at file scope.
///
/// When an enumeration is nested inside an outer discriminator declared with
/// `@Discriminant`, specify `by:` to point to the outer discriminator:
///
/// ```swift
/// @Discriminant public enum TooltipType {
///     @Discriminated(by: TooltipType.self) public enum Union {
///         case text(String)
///         case icon(Int)
///     }
/// }
/// ```
///
/// In this mode, peer synthesis is suppressed, and `var type: TooltipType` is
/// synthesized directly on the nested variant enumeration.
///
/// - Parameters:
///   - by: An optional explicit discriminator type to return from the synthesized
///     `type` property. When specified, peer synthesis is disabled.
///   - backing: An optional raw-value type (such as `Int.self` or `String.self`)
///     for the synthesized peer enumeration.
@attached(
    peer,
    names: suffixed(Type)
) @attached(
    member,
    names: named(type)
) public macro Discriminated(
    by: Any.Type? = nil,
    backing: Any.Type? = nil,
) = #externalMacro(
    module: "LexicMacros",
    type: "DiscriminatedMacro"
)

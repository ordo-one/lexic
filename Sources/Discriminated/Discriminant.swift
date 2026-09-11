/// Synthesizes cases on an enumeration matching the cases of a nested variant enumeration,
/// along with an initializer converting from the variant enumeration.
///
/// When modeling a discriminated union where the discriminator tag must be a top-level
/// type (such as for single-token TypeScript API bindings), `@Discriminant` allows you
/// to declare the outer tag enum and nest the payload-bearing variants inside:
///
/// ```swift
/// @Discriminant public enum OrderType {
///     public enum Union {
///         case custom
///         case market(String)
///         case limit(Int)
///     }
/// }
/// ```
///
/// This synthesizes the matching cases and conversion initializer on `OrderType`:
///
/// ```swift
/// public enum OrderType {
///     public enum Union {
///         case custom
///         case market(String)
///         case limit(Int)
///     }
///
///     case custom
///     case market
///     case limit
///
///     @inlinable public init(_ value: Union) {
///         switch value {
///         case .custom: self = .custom
///         case .market: self = .market
///         case .limit: self = .limit
///         }
///     }
/// }
///
/// extension OrderType: CaseIterable, Sendable {}
/// ```
///
/// - Parameters:
///   - of: The name of the nested enumeration containing the payload cases. When omitted
///     or `nil`, the solitary nested enumeration is automatically selected.
@attached(
    member,
    names: arbitrary
) @attached(
    extension,
    conformances: CaseIterable, Sendable
) public macro Discriminant(
    of: String? = nil
) = #externalMacro(
    module: "LexicMacros",
    type: "DiscriminantMacro"
)

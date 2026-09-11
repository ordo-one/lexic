/// Synthesizes discriminator cases and a mapping initializer on an outer enumeration
/// that wraps a nested variant enumeration annotated with `@Discriminated(by:)`.
///
/// When modeling a discriminated union where the discriminator tag must be a top-level
/// type (such as for single-token TypeScript API bindings), `@Discriminant` allows you
/// to declare the outer tag enum and nest the payload-bearing variants inside:
///
/// ```swift
/// @Discriminant public enum OrderType {
///     @Discriminated(by: OrderType.self) public enum Union {
///         case custom
///         case market(String)
///         case limit(Int)
///     }
/// }
/// ```
///
/// This synthesizes the matching cases on `OrderType`:
///
/// ```swift
/// public enum OrderType {
///     public enum Union {
///         case custom
///         case market(String)
///         case limit(Int)
///
///         public var type: OrderType { ... }
///     }
///
///     case custom
///     case market
///     case limit
/// }
/// ```
@attached(
    member,
    names: arbitrary
) public macro Discriminant() = #externalMacro(
    module: "LexicMacros",
    type: "DiscriminantMacro"
)

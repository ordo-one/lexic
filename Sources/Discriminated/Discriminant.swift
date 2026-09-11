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
/// This synthesizes the matching cases and conversion initializer on `OrderType`:
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
@attached(
    member,
    names: arbitrary
) @attached(
    extension,
    conformances: CaseIterable, Sendable
) public macro Discriminant() = #externalMacro(
    module: "LexicMacros",
    type: "DiscriminantMacro"
)

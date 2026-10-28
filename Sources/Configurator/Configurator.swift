/// Synthesizes a peer initializer that omits a trailing configuration closure.
///
/// Initializers that accept a trailing closure for configuring the value being constructed
/// cannot simply default that closure to `{ _ in }` when the closure throws, because the
/// default is upcast to a throwing closure and every call site must then be written with
/// `try`, even when no closure is passed. The `@Configurator` macro generates an overload
/// without the closure that delegates with an explicitly non-throwing closure, so that the
/// closure’s error type is resolved to `Never` and the overload does not throw:
///
/// ```swift
/// struct Account {
///     @Configurator init<E>(
///         name: String,
///         body: (inout Self) throws(E) -> ()
///     ) throws(E) {
///         self.name = name
///         try body(&self)
///     }
/// }
/// ```
///
/// This synthesizes the following peer initializer on `Account`:
///
/// ```swift
/// init(name: String) {
///     self.init(name: name, body: { (_: inout Self) throws(Never) -> () in })
/// }
/// ```
///
/// The peer preserves the preceding parameters, access control, failability, `async`, and
/// mirrored attributes such as `@available`, `@inlinable`, `@_spi`, and `@MainActor`. If the
/// closure’s error type is a generic parameter of the initializer that is not referenced
/// anywhere else in the signature, and that is constrained to nothing but `Error`, it is
/// removed from the peer. If the initializer uses `rethrows` and has no other throwing
/// closure parameters, optional or not, the peer does not throw. Otherwise the peer keeps the
/// original throws clause and delegates with `try`.
///
/// > Note: The `convenience` modifier is inserted automatically when the initializer is
/// declared directly inside a class. Inside an extension of a class, write `convenience`
/// on the original initializer and it will be mirrored. The `override` modifier is never
/// copied, and the macro cannot be applied to a protocol requirement.
@attached(
    peer,
    names: overloaded
) public macro Configurator() = #externalMacro(
    module: "LexicMacros",
    type: "ConfiguratorMacro"
)

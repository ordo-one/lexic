import SwiftSyntaxMacrosGenericTestSupport
import Testing

@Suite struct ConfiguratorExpansion {
    @Test static func TypedError() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }

                init(x: Int) {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func MultipleGenerics() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<T: Sendable, E>(
                    x: T,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) where T: Hashable {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<T: Sendable, E>(
                    x: T,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) where T: Hashable {
                }

                init<T: Sendable>(x: T) where T: Hashable {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func Rethrowing() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(x: Int, body: (inout Self) throws -> ()) rethrows {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(x: Int, body: (inout Self) throws -> ()) rethrows {
                }

                init(x: Int) {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func RethrowingWithOtherClosure() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(
                    first: () throws -> (),
                    body: (inout Self) throws -> ()
                ) rethrows {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(
                    first: () throws -> (),
                    body: (inout Self) throws -> ()
                ) rethrows {
                }

                init(first: () throws -> ()) rethrows {
                    try self.init(first: first, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func Unconditional() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(x: Int, body: (inout Self) throws -> ()) throws {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(x: Int, body: (inout Self) throws -> ()) throws {
                }

                init(x: Int) throws {
                    try self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func AsynchronousTypedError() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) async throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) async throws(E) {
                }

                init(x: Int) async {
                    await self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func AsynchronousUnconditional() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(x: Int, body: (inout Self) throws -> ()) async throws {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(x: Int, body: (inout Self) throws -> ()) async throws {
                }

                init(x: Int) async throws {
                    try await self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func Convenience() {
        let expansion: Expansion = .init(
            """
            class C {
                @Configurator init<E>(x: Int, body: (C) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            class C {
                init<E>(x: Int, body: (C) throws(E) -> ()) throws(E) {
                }

                convenience init(x: Int) {
                    self.init(x: x, body: { (_: C) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func ConvenienceAlreadyPresent() {
        let expansion: Expansion = .init(
            """
            class C {
                @Configurator convenience init<E>(x: Int, body: (C) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            class C {
                convenience init<E>(x: Int, body: (C) throws(E) -> ()) throws(E) {
                }

                convenience init(x: Int) {
                    self.init(x: x, body: { (_: C) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func Failable() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init?<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init?<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }

                init?(x: Int) {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func ModifiersAndAttributes() {
        let expansion: Expansion = .init(
            """
            struct S {
                @available(macOS 15, *)
                @inlinable @Configurator public nonisolated
                init<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                @available(macOS 15, *)
                @inlinable public nonisolated
                init<E>(x: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }

                @available(macOS 15, *) @inlinable public nonisolated init(x: Int) {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func SPI() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator @_spi(Private) public init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                @_spi(Private) public init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }

                @_spi(Private) public init(x: Int) {
                    self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func Forwarding() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(
                    _ a: Int,
                    b c: Int,
                    d: inout Int,
                    e: @escaping () -> (),
                    f: String = "f",
                    `default` g: Int = 0,
                    _ body: (inout Self, Int) throws(E) -> Void,
                ) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(
                    _ a: Int,
                    b c: Int,
                    d: inout Int,
                    e: @escaping () -> (),
                    f: String = "f",
                    `default` g: Int = 0,
                    _ body: (inout Self, Int) throws(E) -> Void,
                ) throws(E) {
                }

                init(_ a: Int, b c: Int, d: inout Int, e: @escaping () -> (), f: String = "f", `default` g: Int = 0) {
                    self.init(a, b: c, d: &d, e: e, f: f, default: g, { (_: inout Self, _: Int) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }

    @Test static func ConcreteError() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(x: Int, body: (inout Self) throws(Failure) -> ()) throws(Failure) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(x: Int, body: (inout Self) throws(Failure) -> ()) throws(Failure) {
                }

                init(x: Int) throws(Failure) {
                    try self.init(x: x, body: { (_: inout Self) throws(Never) -> () in
                        })
                }
            }
            """
        )
    }
}

import SwiftSyntaxMacrosGenericTestSupport
import Testing

@Suite struct ConfiguratorDiagnostics {
    @Test static func NotAnInitializer() {
        let expansion: Expansion = .init(
            """
            @Configurator func f(body: (Int) throws -> ()) rethrows {
            }
            """
        )
        expansion.expect(
            """
            func f(body: (Int) throws -> ()) rethrows {
            }
            """,
            diagnostics: [
                .init(
                    message: "‘@Configurator’ must be applied to an initializer",
                    line: 1,
                    column: 1
                ),
            ]
        )
    }

    @Test static func NoParameters() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init() {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init() {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    ‘@Configurator’ initializer must declare a trailing closure parameter
                    """,
                    line: 2,
                    column: 23
                ),
            ]
        )
    }

    @Test static func NotAClosure() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(x: Int) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(x: Int) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    final parameter of ‘@Configurator’ initializer must be a closure
                    """,
                    line: 2,
                    column: 27
                ),
            ]
        )
    }

    @Test static func NonVoidClosure() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(body: (inout Self) throws -> Int) rethrows {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(body: (inout Self) throws -> Int) rethrows {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: "configuration closure must return ‘Void’",
                    line: 2,
                    column: 53
                ),
            ]
        )
    }

    @Test static func NonThrowingClosure() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init(body: (inout Self) -> ()) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init(body: (inout Self) -> ()) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    configuration closure does not throw; provide a default argument \
                    ‘= { _ in }’ instead of using ‘@Configurator’
                    """,
                    line: 2,
                    column: 30
                ),
            ]
        )
    }

    @Test static func Variadic() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(x: Int..., body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(x: Int..., body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: "‘@Configurator’ cannot forward variadic parameters",
                    line: 2,
                    column: 33
                ),
            ]
        )
    }

    @Test static func Unnamed() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(x _: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(x _: Int, body: (inout Self) throws(E) -> ()) throws(E) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: "‘@Configurator’ cannot forward unnamed parameters",
                    line: 2,
                    column: 27
                ),
            ]
        )
    }

    @Test static func ErrorInOtherParameter() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(
                    first: () throws(E) -> (),
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(
                    first: () throws(E) -> (),
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    error type ‘E’ of configuration closure is referenced by another \
                    parameter and cannot be removed from the generated initializer
                    """,
                    line: 3,
                    column: 16
                ),
            ]
        )
    }

    @Test static func ErrorInClosureParameter() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(body: (inout Self, E) throws(E) -> ()) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<E>(body: (inout Self, E) throws(E) -> ()) throws(E) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    error type ‘E’ of configuration closure is referenced by a closure \
                    parameter and cannot be removed from the generated initializer
                    """,
                    line: 2,
                    column: 46
                ),
            ]
        )
    }

    @Test static func ErrorInGenericConstraint() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<T: Wrapper<E>, E>(
                    x: T,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }
            }
            """
        )
        expansion.expect(
            """
            struct S {
                init<T: Wrapper<E>, E>(
                    x: T,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    error type ‘E’ of configuration closure is referenced by another \
                    generic parameter and cannot be removed from the generated initializer
                    """,
                    line: 2,
                    column: 24
                ),
            ]
        )
    }

    @Test static func ErrorInWhereClause() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) throws(E) where E: Hashable {
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
                ) throws(E) where E: Hashable {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    error type ‘E’ of configuration closure is constrained in a \
                    ‘where’ clause and cannot be removed from the generated initializer
                    """,
                    line: 5,
                    column: 23
                ),
            ]
        )
    }

    @Test static func ErrorInThrownType() {
        let expansion: Expansion = .init(
            """
            struct S {
                @Configurator init<E>(
                    x: Int,
                    body: (inout Self) throws(E) -> ()
                ) throws(Wrapper<E>) {
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
                ) throws(Wrapper<E>) {
                }
            }
            """,
            diagnostics: [
                .init(
                    message: """
                    error type ‘E’ of configuration closure is referenced by the thrown \
                    error type of the initializer and cannot be removed from the generated \
                    initializer
                    """,
                    line: 5,
                    column: 7
                ),
            ]
        )
    }
}

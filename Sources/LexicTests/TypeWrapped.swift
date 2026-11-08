import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeWrapped {
    @Test static func Sugared() {
        let type: TypeSyntax = "Int?"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "Int")
    }
    @Test static func ImplicitlyUnwrapped() {
        let type: TypeSyntax = "Int!"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "Int")
    }
    @Test static func Unsugared() {
        let type: TypeSyntax = "Optional<Int>"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "Int")
    }
    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Optional<Int>"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "Int")
    }
    @Test static func Attributed() {
        let type: TypeSyntax = "@escaping (() throws -> Int)?"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "(() throws -> Int)")
    }
    @Test static func Parenthesized() {
        let type: TypeSyntax = "(Int?)"
        #expect(type.wrapped.map { "\($0.trimmed)" } == "Int")
    }
    @Test static func Plain() {
        let type: TypeSyntax = "Int"
        #expect(type.wrapped == nil)
    }
    @Test static func ForeignOptional() {
        let type: TypeSyntax = "Foo.Optional<Int>"
        #expect(type.wrapped == nil)
    }
}

import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsOptional {
    @Test static func Sugared() {
        let type: TypeSyntax = "Int?"
        #expect(type.isOptional)
    }

    @Test static func Unsugared() {
        let type: TypeSyntax = "Optional<Int>"
        #expect(type.isOptional == false)
    }

    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Optional<Int>"
        #expect(type.isOptional == false)
    }

    @Test static func Parenthesized() {
        let sugared: TypeSyntax = "(Int?)"
        #expect(sugared.isOptional)

        let unsugared: TypeSyntax = "(Optional<Int>)"
        #expect(unsugared.isOptional == false)
    }

    @Test static func Attributed() {
        let type: TypeSyntax = "@Sendable Int?"
        #expect(type.isOptional)
    }

    @Test static func NonOptional() {
        let type: TypeSyntax = "Int"
        #expect(type.isOptional == false)
    }

    @Test static func Nested() {
        let type: TypeSyntax = "[Int?]"
        #expect(type.isOptional == false)
    }
}

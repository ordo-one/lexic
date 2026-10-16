import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsUnsugaredOptional {
    @Test static func Simple() {
        let type: TypeSyntax = "Optional<Int>"
        #expect(type.isUnsugaredOptional)
    }

    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Optional<Int>"
        #expect(type.isUnsugaredOptional)
    }

    @Test static func Backticks() {
        let identifier: TypeSyntax = "`Optional`<Int>"
        #expect(identifier.isUnsugaredOptional)

        let member: TypeSyntax = "`Swift`.`Optional`<Int>"
        #expect(member.isUnsugaredOptional)

        let tokenSingle: TokenSyntax = .identifier("`Optional`")
        #expect(tokenSingle.unescaped == "Optional")

        let tokenMultiple: TokenSyntax = .identifier("```Optional```")
        #expect(tokenMultiple.unescaped == "Optional")
    }

    @Test static func Parenthesized() {
        let type: TypeSyntax = "(Optional<Int>)"
        #expect(type.isUnsugaredOptional)
    }

    @Test static func Attributed() {
        let type: TypeSyntax = "@Sendable Optional<Int>"
        #expect(type.isUnsugaredOptional)
    }

    @Test static func Sugared() {
        let type: TypeSyntax = "Int?"
        #expect(type.isUnsugaredOptional == false)
    }

    @Test static func NonOptional() {
        let type: TypeSyntax = "Int"
        #expect(type.isUnsugaredOptional == false)
    }

    @Test static func Nested() {
        let type: TypeSyntax = "[Optional<Int>]"
        #expect(type.isUnsugaredOptional == false)
    }

    @Test static func MissingTypeArguments() {
        let type: TypeSyntax = "Optional"
        #expect(type.isUnsugaredOptional == false)
    }

    @Test static func ExcessTypeArguments() {
        let type: TypeSyntax = "Optional<Int, String>"
        #expect(type.isUnsugaredOptional == false)
    }
}

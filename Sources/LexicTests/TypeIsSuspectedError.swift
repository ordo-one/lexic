import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsSuspectedError {
    @Test static func Named() {
        let type: TypeSyntax = "Error"
        #expect(type.isSuspectedError)
    }
    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Error"
        #expect(type.isSuspectedError)
    }
    @Test static func Backticks() {
        let type: TypeSyntax = "`Error`"
        #expect(type.isSuspectedError)
    }
    @Test static func Parenthesized() {
        let type: TypeSyntax = "(Error)"
        #expect(type.isSuspectedError)
    }
    @Test static func Nominal() {
        let type: TypeSyntax = "Int"
        #expect(type.isSuspectedError == false)
    }
    @Test static func ForeignError() {
        let type: TypeSyntax = "Foo.Error"
        #expect(type.isSuspectedError == false)
    }
    @Test static func Composition() {
        let type: TypeSyntax = "Error & Sendable"
        #expect(type.isSuspectedError == false)
    }
}

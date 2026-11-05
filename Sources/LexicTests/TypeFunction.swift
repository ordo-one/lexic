import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeFunction {
    @Test static func Plain() {
        let type: TypeSyntax = "(inout Self) throws -> ()"
        #expect(type.function != nil)
    }
    @Test static func Attributed() {
        let type: TypeSyntax = "@escaping @Sendable (Int) -> ()"
        #expect(type.function != nil)
    }
    @Test static func Parenthesized() {
        let type: TypeSyntax = "((Int) -> ())"
        #expect(type.function != nil)
    }
    @Test static func Optional() {
        let type: TypeSyntax = "((Int) -> ())?"
        #expect(type.function == nil)
    }
    @Test static func Nominal() {
        let type: TypeSyntax = "Int"
        #expect(type.function == nil)
    }
}

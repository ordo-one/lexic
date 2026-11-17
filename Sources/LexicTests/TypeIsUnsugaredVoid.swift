import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsUnsugaredVoid {
    @Test static func Named() {
        let type: TypeSyntax = "Void"
        #expect(type.isUnsugaredVoid)
    }
    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Void"
        #expect(type.isUnsugaredVoid)
    }
    @Test static func Backticks() {
        let type: TypeSyntax = "`Void`"
        #expect(type.isUnsugaredVoid)
    }
    @Test static func Parenthesized() {
        let type: TypeSyntax = "(Void)"
        #expect(type.isUnsugaredVoid)
    }
    @Test static func Attributed() {
        let type: TypeSyntax = "@Sendable Void"
        #expect(type.isUnsugaredVoid)
    }
    @Test static func EmptyTuple() {
        let type: TypeSyntax = "()"
        #expect(type.isUnsugaredVoid == false)
    }
    @Test static func Nominal() {
        let type: TypeSyntax = "Int"
        #expect(type.isUnsugaredVoid == false)
    }
    @Test static func ForeignVoid() {
        let type: TypeSyntax = "Foo.Void"
        #expect(type.isUnsugaredVoid == false)
    }
    @Test static func GenericVoid() {
        let type: TypeSyntax = "Void<Int>"
        #expect(type.isUnsugaredVoid == false)
    }
}

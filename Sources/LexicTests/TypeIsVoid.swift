import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsVoid {
    @Test static func EmptyTuple() {
        let type: TypeSyntax = "()"
        #expect(type.isVoid)
    }
    @Test static func Named() {
        let type: TypeSyntax = "Void"
        #expect(type.isVoid)
    }
    @Test static func Qualified() {
        let type: TypeSyntax = "Swift.Void"
        #expect(type.isVoid)
    }
    @Test static func Parenthesized() {
        let type: TypeSyntax = "(Void)"
        #expect(type.isVoid)
    }
    @Test static func Nominal() {
        let type: TypeSyntax = "Int"
        #expect(type.isVoid == false)
    }
    @Test static func Tuple() {
        let type: TypeSyntax = "(Int, Int)"
        #expect(type.isVoid == false)
    }
    @Test static func ForeignVoid() {
        let type: TypeSyntax = "Foo.Void"
        #expect(type.isVoid == false)
    }
}

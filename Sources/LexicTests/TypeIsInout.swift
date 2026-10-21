import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeIsInout {
    @Test static func Inout() {
        let type: TypeSyntax = "inout Int"
        #expect(type.isInout)
    }
    @Test static func Borrowing() {
        let type: TypeSyntax = "borrowing Int"
        #expect(type.isInout == false)
    }
    @Test static func Plain() {
        let type: TypeSyntax = "Int"
        #expect(type.isInout == false)
    }
}

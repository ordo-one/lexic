import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeInout {
    @Test static func Inout() {
        let type: TypeSyntax = "inout Int"
        #expect(type.`inout`)
    }
    @Test static func Borrowing() {
        let type: TypeSyntax = "borrowing Int"
        #expect(type.`inout` == false)
    }
    @Test static func Plain() {
        let type: TypeSyntax = "Int"
        #expect(type.`inout` == false)
    }
}

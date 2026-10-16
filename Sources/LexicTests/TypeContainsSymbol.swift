import Lexic
import SwiftSyntax
import Testing

@Suite struct TypeContainsSymbol {
    @Test static func Nominal() {
        let type: TypeSyntax = "E"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func NominalBackticks() {
        let type: TypeSyntax = "`E`"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func NominalWithGenericArguments() {
        let type: TypeSyntax = "Foo.Bar<E>"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func SugaredArray() {
        let type: TypeSyntax = "[E]"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func SugaredDictionary() {
        let type: TypeSyntax = "[T: E]"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func SugaredOptional() {
        let type: TypeSyntax = "E?"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func Function() {
        let type: TypeSyntax = "() throws(E) -> ()"
        #expect(type.contains(symbol: "E"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func FunctionSelf() {
        let type: TypeSyntax = "() throws -> Self"
        #expect(type.contains(symbol: "Self"))
        #expect(type.contains(symbol: "F") == false)
    }
    @Test static func FunctionSelfBackticks() {
        let type: TypeSyntax = "() throws -> `Self`"
        #expect(type.contains(symbol: "Self"))
        #expect(type.contains(symbol: "F") == false)
    }


    @Test static func RejectNested() {
        let type: TypeSyntax = "Foo.E"
        #expect(type.contains(symbol: "E") == false)
        #expect(type.contains(symbol: "F") == false)
    }
}

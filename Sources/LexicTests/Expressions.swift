import Testing
import SwiftSyntax
import Lexic

@Suite struct Expressions {
    @Test static func Identifier() throws {
        let node: AttributeSyntax = """
        @Attribute(x: .a)
        """

        let value: Attribute = try .init(decoding: node)
        #expect(value.x == .a)
    }

    @Test static func IdentifierSelf() throws {
        let node: AttributeSyntax = """
        @Attribute(x: .self)
        """

        let value: Attribute = try .init(decoding: node)
        #expect(value.x == .self)
    }

    @Test static func Integer() throws {
        let node: AttributeSyntax = """
        @Attribute(y: 5)
        """

        let value: Attribute = try .init(decoding: node)
        #expect(value.y == 5)
    }
    @Test static func IntegerPrefixMinus() throws {
        let node: AttributeSyntax = """
        @Attribute(y: -5)
        """

        let value: Attribute = try .init(decoding: node)
        #expect(value.y == -5)
    }
    @Test static func IntegerPrefixPlus() throws {
        let node: AttributeSyntax = """
        @Attribute(y: +5)
        """

        let value: Attribute = try .init(decoding: node)
        #expect(value.y == +5)
    }

    @Test static func MetatypeArray() throws {
        let node: AttributeSyntax = """
        @Attribute(type: [Int].self)
        """

        let value: Metatype = try .init(decoding: node)
        let expected: ArrayTypeSyntax = .init(element: IdentifierTypeSyntax.init(name: "Int"))
        /// direct `==` comparison will fail, likely due to source location metadata
        #expect("\(value.type)" == "\(TypeSyntax.init(expected))")
    }
}

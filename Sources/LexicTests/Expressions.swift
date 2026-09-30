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

    @Test static func FunctionCall() throws {
        let expr: ExprSyntax = """
        MyFunc(name: "hello", value: 42)
        """
        let node: FunctionCallExprSyntax = expr.cast(FunctionCallExprSyntax.self)

        let value: Call = try .init(decoding: node)
        #expect(value.name == "hello")
        #expect(value.value == 42)
    }

    @Test static func FunctionCallMissingArgument() throws {
        let expr: ExprSyntax = """
        MyFunc(value: 42)
        """
        let node: FunctionCallExprSyntax = expr.cast(FunctionCallExprSyntax.self)

        #expect {
            try Call.init(decoding: node)
        } throws: { error in
            guard case ExpressionListDecodingError.missing(let label, in: let owner) = error else {
                return false
            }
            return label?.text == "name" && owner.trimmedDescription == "MyFunc"
        }
    }

    @Test static func CustomExpectedDescription() throws {
        let expr: ExprSyntax = """
        "0OIl"
        """
        let node: StringLiteralExprSyntax = expr.cast(StringLiteralExprSyntax.self)
        #expect {
            try Base58.init(from: node)
        } throws: { error in
            guard let error: ExpressionDecodingError = error as? ExpressionDecodingError else {
                return false
            }
            return error.description == "expected a base58 string literal"
        }
    }
}




public import SwiftSyntax

public protocol ExpressionDecodable<Node> {
    associatedtype Node: ExprSyntaxProtocol
    init(from node: borrowing Node) throws(ExpressionDecodingError)
}
extension ExpressionDecodable where Self: RawRepresentable, RawValue: ExpressionDecodable {
    public init(from node: borrowing RawValue.Node) throws(ExpressionDecodingError) {
        guard let value: Self = .init(rawValue: try .init(from: node)) else {
            throw node.expected("an instance of '\(String.init(reflecting: Self.self))'")
        }
        self = value
    }
}
extension ExpressionDecodable where Self: LosslessStringConvertible & FixedWidthInteger {
    public init(from node: borrowing ExprSyntax) throws(ExpressionDecodingError) {
        let text: String
        if  let node: IntegerLiteralExprSyntax = node.as(IntegerLiteralExprSyntax.self),
            case .integerLiteral(let integer) = node.literal.tokenKind {
            text = integer
        } else if
            let signed: PrefixOperatorExprSyntax = node.as(PrefixOperatorExprSyntax.self),
            let node: IntegerLiteralExprSyntax = signed.expression.as(
                IntegerLiteralExprSyntax.self
            ),
            case .prefixOperator(let sign) = signed.operator.tokenKind,
            case .integerLiteral(let integer) = node.literal.tokenKind {

            switch sign {
            case "+":
                text = integer
            case "-":
                text = "\(sign)\(integer)"
            default:
                throw .init(
                    text: "only '-' and '+' may appear prefixed to an integer literal",
                    node: signed.operator
                )
            }
        } else {
            throw node.expected("an integer literal")
        }

        guard let value: Self = .init(text) else {
            throw node.expected(
                "integer literal '\(text)' overflows '\(String.init(reflecting: Self.self))'"
            )
        }
        self = value
    }
}

import SwiftSyntax

protocol ExpressionDecodable<Node> {
    associatedtype Node: ExprSyntaxProtocol
    init(from node: borrowing Node) throws(ExpressionDecodingError)
}
extension ExpressionDecodable where Self: RawRepresentable, RawValue: ExpressionDecodable {
    init(from node: borrowing RawValue.Node) throws(ExpressionDecodingError) {
        guard let value: Self = .init(rawValue: try .init(from: node)) else {
            throw node.expected("an instance of '\(String.init(reflecting: Self.self))'")
        }
        self = value
    }
}
extension ExpressionDecodable where Self: LosslessStringConvertible & FixedWidthInteger {
    init(from node: borrowing IntegerLiteralExprSyntax) throws(ExpressionDecodingError) {
        guard case .integerLiteral(let text) = node.literal.tokenKind else {
            fatalError("unreachable")
        }
        guard let value: Self = .init(text) else {
            throw node.expected(
                "integer literal '\(text)' overflows '\(String.init(reflecting: Self.self))'"
            )
        }
        self = value
    }
}

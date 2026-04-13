public import SwiftSyntax

public protocol ExpressionDecodableFromStringLiteral:
    ExpressionDecodable<StringLiteralExprSyntax> {
    init?(_ string: String)
}
extension ExpressionDecodableFromStringLiteral {
    public init(from node: borrowing StringLiteralExprSyntax) throws(ExpressionDecodingError) {
        guard
        case .stringSegment(let segment)? = node.segments.first,
        case 1 = node.segments.count else {
            throw node.expected("a string literal")
        }

        guard
        let value: Self = .init(segment.content.text) else {
            throw node.expected("a valid instance of \(String.init(reflecting: Self.self))")
        }

        self = value
    }
}

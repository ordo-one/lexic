public import SwiftSyntax

public protocol ExpressionDecodableFromStringLiteral:
    ExpressionDecodable<StringLiteralExprSyntax> {
    /// The expected syntax or semantic form used in diagnostic messages.
    /// Defaults to “a valid instance of <Type>”.
    static var expectation: String { get }

    init?(_ string: String)
}
extension ExpressionDecodableFromStringLiteral {
    public static var expectation: String {
        "a valid instance of \(String.init(reflecting: Self.self))"
    }

    public init(from node: borrowing StringLiteralExprSyntax) throws(ExpressionDecodingError) {
        guard
        case .stringSegment(let segment)? = node.segments.first,
        case 1 = node.segments.count else {
            throw node.expected("a string literal")
        }

        guard
        let value: Self = .init(segment.content.text) else {
            throw node.expected(Self.expectation)
        }

        self = value
    }
}

public import SwiftSyntax

public protocol ExpressionDecodableFromStringLiteral:
    ExpressionDecodable<StringLiteralExprSyntax> {
    /// A human-readable description of the expected value used in diagnostic messages.
    /// Defaults to “a valid instance of <Type>”.
    static var expectedDescription: String { get }

    init?(_ string: String)
}
extension ExpressionDecodableFromStringLiteral {
    public static var expectedDescription: String {
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
            throw node.expected(Self.expectedDescription)
        }

        self = value
    }
}

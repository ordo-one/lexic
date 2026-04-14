public import SwiftSyntax

public protocol ExpressionDecodableFromIdentifier: ExpressionDecodable {
    init(base: ExprSyntax?, name: TokenSyntax) throws(ExpressionDecodingError)
}
extension ExpressionDecodableFromIdentifier {
    public init(from node: borrowing MemberAccessExprSyntax) throws(ExpressionDecodingError) {
        guard
        case nil = node.declName.moduleSelector,
        case nil = node.declName.argumentNames else {
            throw node.expected("a bare property reference")
        }

        try self.init(base: node.base, name: node.declName.baseName)
    }
}
extension ExpressionDecodableFromIdentifier where Self: RawRepresentable<String> {
    public init(base: ExprSyntax?, name: TokenSyntax) throws(ExpressionDecodingError) {
        if  let base: ExprSyntax {
            throw .init(
                text: "enum case expression must be written with leading dot syntax",
                node: base
            )
        }
        guard let value: Self = .init(rawValue: name.text) else {
            throw .init(
                text: "expected a case of '\(String.init(reflecting: Self.self))'",
                node: name
            )
        }

        self = value
    }
}

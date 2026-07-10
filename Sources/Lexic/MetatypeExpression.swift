public import SwiftSyntax
internal import SwiftParser

@frozen public struct MetatypeExpression {
    public let type: TypeSyntax
}
extension MetatypeExpression: ExpressionDecodable {
    public init(from node: borrowing MemberAccessExprSyntax) throws(ExpressionDecodingError) {
        guard
        case .keyword(.self) = node.declName.baseName.tokenKind,
        case nil = node.declName.argumentNames,
        let base: ExprSyntax = node.base else {
            fatalError("unreachable")
        }

        // types like `[Int].self` look like ``ArrayExprSyntax``, not ``ArrayTypeSyntax``,
        // so it is necessary to render and reparse
        self.init(type: "\(base.trimmed)")
    }
}

public import SwiftSyntax

extension Set: ExpressionDecodable where Element: ExpressionDecodable {
    public init(from node: borrowing ArrayExprSyntax) throws(ExpressionDecodingError) {
        self = []
        for element: ArrayElementSyntax in node.elements {
            let next: Element = try .init(
                from: try element.expression.expecting(Element.Node.self)
            )
            guard case nil = self.update(with: next) else {
                throw .init(
                    text: "expected a set literal with unique elements",
                    node: element.expression
                )
            }
        }
    }
}

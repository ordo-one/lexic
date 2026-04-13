import SwiftSyntax

extension ExprSyntaxProtocol {
    func expected(_ what: String) -> ExpressionDecodingError {
        .init(description: "expected \(what)", node: ExprSyntax.init(self))
    }
}

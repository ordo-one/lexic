import SwiftSyntax

extension ExprSyntaxProtocol {
    func expected(_ what: String) -> ExpressionDecodingError {
        .init(text: "expected \(what)", node: ExprSyntax.init(self))
    }
}

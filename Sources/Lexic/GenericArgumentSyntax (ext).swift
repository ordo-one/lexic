import SwiftSyntax

extension GenericArgumentSyntax {
    func contains(symbol: String) -> Bool {
        guard case .type(let type) = self.argument else {
            return false
        }
        return type.contains(symbol: symbol)
    }
}

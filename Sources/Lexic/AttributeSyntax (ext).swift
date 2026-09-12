public import SwiftSyntax

extension AttributeSyntax {
    public var baseName: String? {
        guard
        let identifier: IdentifierTypeSyntax = self.attributeName.as(
            IdentifierTypeSyntax.self
        ) else {
            return nil
        }
        return identifier.name.text
    }
}

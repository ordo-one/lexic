import SwiftSyntax
import SwiftSyntaxMacros

struct EquatableMacro: PeerMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingPeersOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        if  let type: StructDeclSyntax = decl.as(StructDeclSyntax.self) {
            return self.expansion(of: attribute, in: context, decl: type)
        } else {
            return []
        }
    }
}
extension EquatableMacro {
    private static func expansion(
        of attribute: AttributeSyntax,
        in context: some MacroExpansionContext,
        decl: StructDeclSyntax,
    ) -> [DeclSyntax] {
        return []
    }
}

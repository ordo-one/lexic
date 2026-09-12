import Lexic
import SwiftSyntax
import SwiftSyntaxMacros

struct DiscriminatedMacro {}
extension DiscriminatedMacro: PeerMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingPeersOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: EnumDeclSyntax = decl.as(EnumDeclSyntax.self) else {
            context[.error, decl] = "‘@Discriminated’ must be applied to an enum"
            return []
        }

        guard let configuration: Configuration = .init(decoding: attribute, in: context) else {
            return []
        }

        guard configuration.by == nil else {
            return []
        }

        let casesList: MemberBlockItemListSyntax = .init {
            for element: EnumCaseElementSyntax in decl.caseElements {
                EnumCaseDeclSyntax.init(case: element.name)
            }
        }

        let peerTypeName: String = "\(decl.name.text)Type"
        let peer: DeclSyntax = """
        \(decl.attributesForPeerType)\
        \(decl.modifiersForMember)enum \(raw: peerTypeName)\
        \(raw: configuration.backing.map { ": \($0)" } ?? "") {
        \(casesList)
        }
        """

        return [peer]
    }
}
extension DiscriminatedMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: EnumDeclSyntax = decl.as(EnumDeclSyntax.self) else {
            context[.error, decl] = "‘@Discriminated’ must be applied to an enum"
            return []
        }

        guard let configuration: Configuration = .init(decoding: attribute, in: context) else {
            return []
        }

        // Discriminator ‘type’ property
        let peerTypeName: String = if let by: TypeSyntax = configuration.by {
            by.trimmedDescription
        } else {
            "\(decl.name.text)Type"
        }
        let typeCases: [String] = decl.caseElements.map { "case .\($0.name): .\($0.name)" }
        let typeProperty: DeclSyntax = """
        \(raw: decl.inlinable)\(decl.modifiersForMember)var type: \(raw: peerTypeName) {
            switch self {
            \(raw: typeCases.joined(separator: "\n    "))
            }
        }
        """
        return [typeProperty]
    }
}

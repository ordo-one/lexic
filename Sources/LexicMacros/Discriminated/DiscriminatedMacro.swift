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

        guard
        let configuration: Configuration = .init(decoding: attribute, in: context) else {
            return []
        }
        if  case _? = configuration.by {
            return []
        }

        let cases: MemberBlockItemListSyntax = .init {
            for element: EnumCaseElementSyntax in decl.cases {
                EnumCaseDeclSyntax.init(case: element.name)
            }
        }

        let type: String = "\(decl.name.text)Type"
        let peer: DeclSyntax = """
        \(decl.attributes.mirroredAsTypeForType)\(decl.modifiersForMember)\
        enum \(raw: type)\
        \(raw: configuration.backing.map { ": \($0)" } ?? "") {
        \(cases)
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
        let type: String = if let by: TypeSyntax = configuration.by {
            by.trimmedDescription
        } else {
            "\(decl.name.text)Type"
        }
        let cases: [String] = decl.cases.map { "case .\($0.name): .\($0.name)" }
        let typeProperty: DeclSyntax = """
        \(decl.attributes.mirroredAsTypeForMember)\
        \(raw: decl.inlinable)\(decl.modifiersForMember)var type: \(raw: type) {
            switch self {
            \(raw: cases.joined(separator: "\n    "))
            }
        }
        """
        return [typeProperty]
    }
}

import Lexic
import SwiftSyntax
import SwiftSyntaxMacros

struct DiscriminatedMacro {}
extension DiscriminatedMacro {
    static func cases(of decl: EnumDeclSyntax) -> [Case] {
        var cases: [Case] = []
        for member: MemberBlockItemSyntax in decl.memberBlock.members {
            guard let enumCase: EnumCaseDeclSyntax = member.decl.as(
                EnumCaseDeclSyntax.self
            ) else {
                continue
            }
            for element: EnumCaseElementSyntax in enumCase.elements {
                cases.append(.init(from: element))
            }
        }
        return cases
    }
}
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

        let cases: [Case] = Self.cases(of: decl)
        let casesList: MemberBlockItemListSyntax = .init {
            for `case`: Case in cases {
                EnumCaseDeclSyntax.init(
                    caseKeyword: .keyword(.case, trailingTrivia: .spaces(1))
                ) {
                    EnumCaseElementSyntax.init(
                        name: `case`.name,
                        trailingTrivia: .newlines(1)
                    )
                }
            }
        }

        let attributesOnType: [AttributeListSyntax.Element] = decl.attributes.reduce(into: []) {
            guard
            case .attribute(let attribute) = $1,
            let identifier: IdentifierTypeSyntax = attribute.attributeName.as(
                IdentifierTypeSyntax.self
            ) else {
                return
            }
            switch identifier.name.text {
            case "frozen": break
            case "usableFromInline", "_usableFromInline": break
            default: return
            }

            $0.append($1)
        }

        let peerTypeName: String = "\(decl.name.text)Type"
        let peer: DeclSyntax = """
        \(AttributeListSyntax.init(attributesOnType))\
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

        let cases: [Case] = Self.cases(of: decl)
        // Discriminator ‘type’ property
        let peerTypeName: String = if let by: TypeSyntax = configuration.by {
            by.trimmedDescription
        } else {
            "\(decl.name.text)Type"
        }
        let typeCases: [String] = cases.map { "case .\($0.name): .\($0.name)" }
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

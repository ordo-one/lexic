import Lexic
import SwiftSyntax
import SwiftSyntaxMacros

struct DiscriminantMacro {}
extension DiscriminantMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: EnumDeclSyntax = decl.as(EnumDeclSyntax.self) else {
            context[.error, decl] = "‘@Discriminant’ must be applied to an enum"
            return []
        }

        let candidates: [
            (enum: EnumDeclSyntax, attribute: AttributeSyntax)
        ] = decl.memberBlock.members.reduce(into: []) {
            if  let nested: EnumDeclSyntax = $1.decl.as(EnumDeclSyntax.self),
                let attribute: AttributeSyntax = nested.attributes.first(
                    named: "Discriminated"
                ) {
                $0.append((nested, attribute))
            }
        }

        guard !candidates.isEmpty else {
            context[.error, decl] = """
            ‘@Discriminant’ requires a nested enum annotated with ‘@Discriminated’
            """
            return []
        }
        guard candidates.count == 1, let candidate = candidates.first else {
            context[.error, decl] = """
            ‘@Discriminant’ found multiple nested enums annotated with ‘@Discriminated’
            """
            return []
        }

        if  let config: DiscriminatedMacro.Configuration = .init(
                decoding: candidate.attribute,
                in: context
            ) {
            guard let type: TypeSyntax = config.by else {
                context[.error, candidate.attribute] = """
                ‘@Discriminated’ nested inside ‘@Discriminant’ must specify \
                ‘by: \(decl.name.text).self’
                """
                return []
            }

            let name: Substring?

            switch type.asProtocol((any TypeSyntaxProtocol).self) {
            case let identifier as IdentifierTypeSyntax:
                name = identifier.name.unescaped
            case let member as MemberTypeSyntax:
                name = member.name.unescaped
            default:
                name = nil
            }
            guard case decl.name.unescaped? = name else {
                context[.error, candidate.attribute] = """
                ‘@Discriminated’ must specify ‘by: \(decl.name.text).self’
                """
                return []
            }
        }

        var members: [DeclSyntax] = []
        for element: EnumCaseElementSyntax in candidate.enum.cases {
            members.append(DeclSyntax.init(EnumCaseDeclSyntax.init(case: element.name)))
        }
        return members
    }
}
